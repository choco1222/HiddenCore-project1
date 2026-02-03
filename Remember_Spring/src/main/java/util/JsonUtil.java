package util;

import java.util.List;
import java.util.Map;

import dao.DailyReportDAO;
import dto.NotifDTO;

public class JsonUtil {

    public static String toJson(int unreadCount, List<NotifDTO> items) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"unreadCount\":").append(unreadCount).append(",\"items\":[");

        for (int i = 0; i < items.size(); i++) {
            NotifDTO n = items.get(i);
            if (i > 0) sb.append(",");

            sb.append("{")
              .append("\"key\":\"").append(esc(n.getKey())).append("\",")
              .append("\"id\":").append(n.getId()).append(",")
              .append("\"title\":\"").append(esc(n.getTitle())).append("\",")
              .append("\"body\":\"").append(esc(n.getBody())).append("\",")
              .append("\"type\":\"").append(esc(n.getType())).append("\"")
              .append("}");
        }

        sb.append("]}");
        return sb.toString();
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", " ");
    }
    
    public static String activeLogsToJson(List<DailyReportDAO.ActivelogRow> logs) {
        if (logs == null || logs.isEmpty()) {
            return "[]";
        }
        
        StringBuilder json = new StringBuilder();
        json.append("[");
        for (int i = 0; i < logs.size(); i++) {
            if (i > 0) json.append(",");
            DailyReportDAO.ActivelogRow log = logs.get(i);
            if (log == null) continue;
            
            json.append("{");
            json.append("\"user_id\":").append(log.user_id != null ? "\"" + escapeJson(log.user_id) + "\"" : "null").append(",");
            json.append("\"event_type\":").append(log.event_type != null ? "\"" + escapeJson(log.event_type) + "\"" : "null").append(",");
            json.append("\"event_time\":").append(log.event_time != null ? "\"" + escapeJson(log.event_time) + "\"" : "null").append(",");
            json.append("\"timeSlot\":").append(log.timeSlot != null ? "\"" + escapeJson(log.timeSlot) + "\"" : "null").append(",");
            json.append("\"isDuplicate\":").append(log.isDuplicate);
            json.append("}");
        }
        json.append("]");
        return json.toString();
    }
    
    /**
     * Map을 JSON 문자열로 변환
     * @param map 변환할 Map 객체
     * @return JSON 문자열
     */
    public static String mapToJson(java.util.Map<String, Object> map) {
        if (map == null) return "{}";
        
        StringBuilder json = new StringBuilder();
        json.append("{");
        boolean first = true;
        
        for (java.util.Map.Entry<String, Object> entry : map.entrySet()) {
            if (entry == null) continue;
            
            if (!first) json.append(",");
            String key = entry.getKey();
            if (key == null) key = "";
            json.append("\"").append(escapeJson(key)).append("\":");
            
            Object value = entry.getValue();
            if (value == null) {
                json.append("null");
            } else if (value instanceof String) {
                json.append("\"").append(escapeJson((String)value)).append("\"");
            } else if (value instanceof Number || value instanceof Boolean) {
                json.append(value);
            } else if (value instanceof List) {
                json.append(listToJson((List<?>)value));
            } else if (value instanceof Map) {
                json.append(mapToJson((java.util.Map<String, Object>)value));
            } else {
                json.append("\"").append(escapeJson(value.toString())).append("\"");
            }
            first = false;
        }
        
        json.append("}");
        return json.toString();
    }
    
    /**
     * List를 JSON 문자열로 변환 (내부 메서드)
     * @param list 변환할 List 객체
     * @return JSON 문자열
     */
    private static String listToJson(List<?> list) {
        if (list == null) return "[]";
        
        StringBuilder json = new StringBuilder();
        json.append("[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) json.append(",");
            Object item = list.get(i);
            if (item == null) {
                json.append("null");
            } else if (item instanceof String) {
                json.append("\"").append(escapeJson((String)item)).append("\"");
            } else if (item instanceof Number || item instanceof Boolean) {
                json.append(item);
            } else if (item instanceof List) {
                json.append(listToJson((List<?>)item));
            } else if (item instanceof Map) {
                json.append(mapToJson((java.util.Map<String, Object>)item));
            } else {
                json.append("\"").append(escapeJson(item.toString())).append("\"");
            }
        }
        json.append("]");
        return json.toString();
    }
    
    /**
     * JSON 문자열 이스케이프 처리
     * @param str 이스케이프할 문자열
     * @return 이스케이프된 문자열
     */
    private static String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}

