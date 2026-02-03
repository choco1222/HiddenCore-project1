package KNK.notif.dto;

public class NotifDTO {
    private String key;
    private long id;        // ms
    private String title;
    private String body;
    private String type;    // routineType

    public NotifDTO(String key, long id, String title, String body, String type) {
        this.key = key;
        this.id = id;
        this.title = title;
        this.body = body;
        this.type = type;
    }

    public String getKey() { return key; }
    public long getId() { return id; }
    public String getTitle() { return title; }
    public String getBody() { return body; }
    public String getType() { return type; }

    public void setKey(String key) { this.key = key; }
    public void setId(long id) { this.id = id; }
    public void setTitle(String title) { this.title = title; }
    public void setBody(String body) { this.body = body; }
    public void setType(String type) { this.type = type; }
}
