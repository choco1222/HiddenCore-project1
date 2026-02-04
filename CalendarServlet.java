package active_log;

import java.io.IOException;
import java.util.Calendar;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/CalendarServlet")
public class CalendarServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Calendar today = Calendar.getInstance();
        String yearParam = request.getParameter("year");
        String monthParam = request.getParameter("month");

        int year = yearParam != null ? Integer.parseInt(yearParam) : today.get(Calendar.YEAR);
        int month = monthParam != null ? Integer.parseInt(monthParam) : (today.get(Calendar.MONTH) + 1);

        Calendar cal = Calendar.getInstance();
        cal.set(year, month - 1, 1);
        int firstDayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
        int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);

        request.setAttribute("year", year);
        request.setAttribute("month", month);
        request.setAttribute("firstDayOfWeek", firstDayOfWeek);
        request.setAttribute("daysInMonth", daysInMonth);
        request.setAttribute("prevYear", (month == 1) ? year - 1 : year);
        request.setAttribute("prevMonth", (month == 1) ? 12 : month - 1);
        request.setAttribute("nextYear", (month == 12) ? year + 1 : year);
        request.setAttribute("nextMonth", (month == 12) ? 1 : month + 1);
        request.setAttribute("todayYear", today.get(Calendar.YEAR));
        request.setAttribute("todayMonth", today.get(Calendar.MONTH) + 1);
        request.setAttribute("todayDay", today.get(Calendar.DATE));

        // ★ 여기서 경로를 정확히 맞춰야 합니다!
        // 만약 jsp 폴더 안에 calendar.jsp가 있다면 아래처럼 쓰세요.
        request.getRequestDispatcher("jsp/calendar.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
        
        
    }
}