<!-- 
	content_list.jsp에서 클릭된 일정의 QR코드를 보여주는 페이지
	날짜별로 다른 QR코드를 출력
 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.text.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>View page</title>
<link rel="stylesheet" href="css/style.css">
<script>
// 셀렉트 박스 선택값이 바뀔 때 qr코드를 해당 날짜의 것으로 교체해서 표시
function change(){
	var selectBox = document.getElementById("id-codes");
	var selectedValue = selectBox.options[selectBox.selectedIndex].value;
	var selectedHTML = selectBox.options[selectBox.selectedIndex].innerHTML;
	var tb = document.getElementById("tb");
	// 선택된 option의 value값(=QR코드 png 파일의 경로)으로 img 태그 내용 기입
	var img = "<img src=" + selectedValue + ">";
	document.getElementById("img_out").innerHTML = img;
	
	// 셀렉트 박스 선택값과 같은 값을 가져야 display:visible로 보이게 됨
	for(var i=1; i<tb.rows.length; i++) {
		var temp = tb.rows[i].cells[2].innerHTML.substring(0,4) + "-" + tb.rows[i].cells[2].innerHTML.substring(5,7) + "-" + tb.rows[i].cells[2].innerHTML.substring(8,10);
		
		if(temp != selectedHTML) tb.rows[i].style = "display:none";
		else tb.rows[i].style = "display:visible";
	}
}
</script>
</head>
<body>
<%
	String content_id = request.getParameter("content_id");
	String date="", content_name="", cdatestart="", cdateend="", ctimestart="", ctimeend="", ctimeleft="";
	Connection con = null;
	PreparedStatement stmt = null;
	PreparedStatement stmt_qr = null;
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		String sql = "select * from content_member_list where CONTENT_ID = '"+content_id+"'";
		String sql_qr = "select * from content_list where CONTENT_ID='"+content_id+"' ";
		stmt = con.prepareStatement(sql);
		stmt_qr = con.prepareStatement(sql_qr);
		ResultSet rs = stmt.executeQuery();
		ResultSet rs_qr = stmt_qr.executeQuery();
		if(rs_qr.next()) {
			cdatestart = rs_qr.getString("CONTENT_DATE_START");
			cdateend = rs_qr.getString("CONTENT_DATE_END");
			content_name = rs_qr.getString("CONTENT_NAME");
			ctimestart = rs_qr.getString("CONTENT_TIME_START");
			ctimeend = rs_qr.getString("CONTENT_TIME_END");
			ctimeleft = rs_qr.getString("CONTENT_TIME_LEFT");
		}
		
		SimpleDateFormat nowTime = new SimpleDateFormat("HH:mm");
		java.util.Date start = nowTime.parse(ctimestart);
		int leftTimeHour, leftTimeMin;
		String tempTime = "";
		if(ctimeleft.equals("30")) {
			leftTimeHour = 0;
			leftTimeMin = 30;
			tempTime = "00:30";
		}
		else if(ctimeleft.equals("60")) {
			leftTimeHour = 1;
			leftTimeMin = 0;
			tempTime = "01:00";
		}
		else {
			leftTimeHour = 1;
			leftTimeMin = 30;
			tempTime = "01:30";
		}
		
		Calendar cal = Calendar.getInstance();
		cal.setTime(start);
		
		String time;
		// 시작시간이 여유시간보다 적은 시간일 경우 시작을 00:00 으로 잡음
		if(nowTime.format(cal.getTime()).compareTo(tempTime) < 0) {
			time = "00:00";
		}
		// 그렇지 않으면 여유시간을 뺀 시간으로 잡음
		else {
			cal.add(Calendar.HOUR, -leftTimeHour);
			cal.add(Calendar.MINUTE, -leftTimeMin);
			time = nowTime.format(cal.getTime());
		}
		
		// 시작일~종료일 기간의 날짜 목록 생성
		DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		java.util.Date startDate = df.parse(cdatestart);
		java.util.Date endDate = df.parse(cdateend);
		long diff = (endDate.getTime() - startDate.getTime()) / (24 * 60 * 60 * 1000);
		Integer days = (int)(long)diff + 1;
		cal.setTime(startDate);
		String codePath = request.getContextPath() + "/qrcode/images/" + content_id;
%>
	<h2 style="text-align:center;"><%=content_name %></h2><br>
	날짜 : <select id="id-codes" name="codes" onchange="change()">
<%
		while(true) {	
%>
			<option value="<%=codePath + df.format(cal.getTime()) + ".png" %>"><%=df.format(cal.getTime()) %></option>			
<%
			if(df.format(cal.getTime()).equals(cdateend)) break;
			cal.add(Calendar.DATE, 1); // 날짜 1 증가
		}
		
%>		
	</select>
	
<%
	// 1일 일정은 기간을 따로 표시하지 않음
	if(!cdatestart.equals(cdateend)) out.print("<br>기간 : " + cdatestart + " ~" + cdateend);
	out.print("<br>시간 : " + ctimestart +"~"+ ctimeend);
	out.print("(출석가능시간 : " + time + "부터)");
%>

	<!-- QR코드 표시 부분 (default로 시작일의 QR코드를 표시) -->
	<span id="img_out"><img src="<%=codePath + cdatestart + ".png" %>"></span>
	<p><strong>출석 방법</strong> (사내 wifi 연결 필요)<br>&nbsp;위 QR코드를 스캔해서 나오는 페이지에서<br>&nbsp;사번과 이름을 입력해 출석할 수 있습니다.</p>
<%
	}
	catch(SQLException se) {
		System.out.println("SQL Exception_view_qr.jsp: " + se.getMessage());
	}
	catch(Exception e) {
		System.out.println("Exception_view_qr.jsp: " + e.getMessage());
	}
	finally {
		try {
			if(con!=null) con.close();
			if(stmt!=null) stmt.close();
		}
		catch(SQLException se) {
			System.out.println("Exception");
		}
	}
%>
</body>
</html>