package notif.service;

import java.sql.Connection;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

import notif.dao.ActiveLogDAO;
import notif.dao.RoutineDAO;
import notif.dto.AlarmPlanDTO;
import notif.dto.NotifDTO;

public class NotificationService {

    private static final ZoneId ZONE = ZoneId.of("Asia/Seoul");
    private static final DateTimeFormatter HHMM = DateTimeFormatter.ofPattern("HH:mm");

    private static final int WINDOW_MIN = 2;      // 알림 허용 오차(±2분)
    private static final int LATE_AFTER_MIN = 30; // 30분 뒤 재알림

    private final RoutineDAO routineDAO;
    private final ActiveLogDAO activeLogDAO;

    public NotificationService(RoutineDAO routineDAO, ActiveLogDAO activeLogDAO) {
        this.routineDAO = routineDAO;
        this.activeLogDAO = activeLogDAO;
    }

    public List<NotifDTO> build(Connection con, String userId, long sinceMs) throws Exception {
        Map<String, String> r = routineDAO.selectRoutineMap(con, userId);

        LocalTime breakfast = parseHHmm(r.get("아침_밥"));
        LocalTime lunch     = parseHHmm(r.get("점심_밥"));
        LocalTime dinner    = parseHHmm(r.get("저녁_밥"));
        LocalTime wakeTime  = parseHHmm(r.get("기상시간"));
        LocalTime sleepTime = parseHHmm(r.get("취침시간"));

        Integer preMin  = parseInt(r.get("식전_약"));
        Integer postMin = parseInt(r.get("식후_약"));

        int wakeMedBefore  = Optional.ofNullable(parseInt(r.get("기상_약"))).orElse(30);
        int sleepMedBefore = Optional.ofNullable(parseInt(r.get("취침_약"))).orElse(30);

        LocalDate today = LocalDate.now(ZONE);
        LocalTime now = LocalTime.now(ZONE);

        List<AlarmPlanDTO> plans = new ArrayList<>();

        //취침/기상 알림
        
        
        
        
        
        // ==========================
        // 1) 밥 (정시 + 30분 재알림)
        // ==========================
        addTwoStage(plans, "아침_밥", 1, breakfast, "아침 식사", "아침 식사 시간이에요!", "아침 식사", "아직 아침 식사 기록이 없어요");
        addTwoStage(plans, "점심_밥", 2, lunch,     "점심 식사", "점심 식사 시간이에요!", "점심 식사", "아직 점심 식사 기록이 없어요");
        addTwoStage(plans, "저녁_밥", 3, dinner,    "저녁 식사", "저녁 식사 시간이에요!", "저녁 식사", "아직 저녁 식사 기록이 없어요");

        // ==========================
        // 2) 기상/취침 약 (기상/취침 기준 -N분)
        //    + 30분 재알림
        // ==========================
        if (wakeTime != null) {
            LocalTime base = wakeTime.minusMinutes(wakeMedBefore);
            addTwoStage(plans, "기상_약", 1, base,
                "기상 약", "기상 " + wakeMedBefore + "분 전이에요",
                "기상 약", "아직 기상 약 기록이 없어요");
        }

        if (sleepTime != null) {
            LocalTime base = sleepTime.minusMinutes(sleepMedBefore);
            addTwoStage(plans, "취침_약", 1, base,
                "취침 약", "취침 " + sleepMedBefore + "분 전이에요",
                "취침 약", "아직 취침 약 기록이 없어요");
        }

        // ==========================
        // 3) 식전 약 (식사 기준 -preMin) + 재알림
        // ==========================
        if (preMin != null) {
            if (breakfast != null) addTwoStage(plans, "식전_약", 1, breakfast.minusMinutes(preMin),
                "식전 약", "아침 식사 " + preMin + "분 전이에요. " + "약먹을 시간입니다!",
                "식전 약", "아직 식전 약 기록이 없어요");

            if (lunch != null) addTwoStage(plans, "식전_약", 2, lunch.minusMinutes(preMin),
                "식전 약", "점심 식사 " + preMin + "분 전이에요. " + "약먹을 시간입니다!",
                "식전 약", "아직 식전 약 기록이 없어요");

            if (dinner != null) addTwoStage(plans, "식전_약", 3, dinner.minusMinutes(preMin),
                "식전 약", "저녁 식사 " + preMin + "분 전이에요. " + "약먹을 시간입니다!",
                "식전 약", "아직 식전 약 기록이 없어요");
        }

        // ==========================
        // 4) 식후 약 (식사 기준 +postMin) + 재알림
        // ==========================
        if (postMin != null) {
            if (breakfast != null) addTwoStage(plans, "식후_약", 1, breakfast.plusMinutes(postMin),
                "식후 약", "아침 식사 " + postMin + "분 후예요",
                "식후 약", "아직 식후 약 기록이 없어요");

            if (lunch != null) addTwoStage(plans, "식후_약", 2, lunch.plusMinutes(postMin),
                "식후 약", "점심 식사 " + postMin + "분 후예요",
                "식후 약", "아직 식후 약 기록이 없어요");

            if (dinner != null) addTwoStage(plans, "식후_약", 3, dinner.plusMinutes(postMin),
                "식후 약", "저녁 식사 " + postMin + "분 후예요",
                "식후 약", "아직 식후 약 기록이 없어요");
        }

        // ==========================
        // 5) now 기준으로 “발생해야 할 것”만 필터링
        // ==========================
        List<NotifDTO> out = new ArrayList<>();

        for (AlarmPlanDTO p : plans) {
            LocalTime fire = p.getFireTime();
            if (fire == null) continue;

            // now가 fire ±WINDOW 범위인지
            if (now.isBefore(fire.minusMinutes(WINDOW_MIN)) || now.isAfter(fire.plusMinutes(WINDOW_MIN))) continue;

            long alarmMs = toMs(today, fire);
            if (alarmMs <= sinceMs) continue;

            // 재알림이면: base~base+30 사이에 기록이 있으면 스킵
            if ("LATE".equals(p.getStage())) {
                String eventType = mapToEventType(p.getRoutineType(), p.getSeq());
                boolean done = activeLogDAO.existsEventBetween(con, userId, eventType,
                    p.getBaseTime(), p.getBaseTime().plusMinutes(LATE_AFTER_MIN));
                if (done) continue;
            }

            String key = "ROU_" + userId + "_" + todayKey(today) + "_" + p.getRoutineType() + "_" + p.getSeq() + "_" + p.getStage();

            out.add(new NotifDTO(key, alarmMs, p.getTitle(), p.getBody(), p.getRoutineType()));
        }

        out.sort(Comparator.comparingLong(NotifDTO::getId));
        return out;
    }

    // ---------- private helpers ----------

    private void addTwoStage(List<AlarmPlanDTO> plans,
                             String routineType, int seq, LocalTime baseTime,
                             String titleOn, String bodyOn,
                             String titleLate, String bodyLate) {
        if (baseTime == null) return;
        plans.add(new AlarmPlanDTO(routineType, seq, baseTime, baseTime, "ONTIME", titleOn, bodyOn));
        plans.add(new AlarmPlanDTO(routineType, seq, baseTime, baseTime.plusMinutes(LATE_AFTER_MIN), "LATE", titleLate, bodyLate));
    }

    // ✅ 추천: activelog.event_type을 routineType 그대로 저장하면 매핑 필요 없음
    private String mapToEventType(String routineType, int seq) {
        if (routineType.endsWith("_밥")) {
            return "식사";
        }
        if (routineType.endsWith("_약")) {
            return "약복용";
        }
        return routineType;
    }

    private LocalTime parseHHmm(String s) {
        if (s == null) return null;
        s = s.trim();
        if (s.matches("^\\d{2}:\\d{2}$")) return LocalTime.parse(s, HHMM);
        if (s.matches("^\\d{2}:\\d{2}:\\d{2}$")) return LocalTime.parse(s);
        return null;
    }

    private Integer parseInt(String s) {
        try { return (s == null) ? null : Integer.parseInt(s.trim()); }
        catch (Exception e) { return null; }
    }

    private long toMs(LocalDate date, LocalTime time) {
        return ZonedDateTime.of(date, time, ZONE).toInstant().toEpochMilli();
    }

    private String todayKey(LocalDate d) {
        return String.format("%04d%02d%02d", d.getYear(), d.getMonthValue(), d.getDayOfMonth());
    }
}
