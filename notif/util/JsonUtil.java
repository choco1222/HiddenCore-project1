package notif.util;

import java.util.List;
import notif.dto.NotifDTO;

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
}
