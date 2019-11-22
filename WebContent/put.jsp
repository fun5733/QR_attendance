<!-- 
	세션에서 전달받은 입력값을 DB에 조회
	출석 할 수 있는지 아닌지를 판별해 처리 후 해당 상황의 메시지 출력
 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.text.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="css/style.css">
<title>Put page</title>
</head>
<body>
<div class="center">
<span class="top"></span>
<div class="content">
<%
	request.setCharacterEncoding("UTF-8");
	// 쿠키가 있으면 쿠키 정보를 받아옴
	Cookie[] cookies = request.getCookies();
	if(cookies != null) {
		for(Cookie tempCookie : cookies) {
			if(tempCookie.getName().equals("id")) {
				session.setAttribute("id", tempCookie.getValue());
			}
			if(tempCookie.getName().equals("name")) {
				session.setAttribute("name", tempCookie.getValue());
			}
		}
	}
	
	String id = (String)session.getAttribute("id");
	String name = URLDecoder.decode((String)session.getAttribute("name"), "UTF-8");
	String ctimestart="", ctimeend="", ctimeleft="", content_date="", content_id="";
	content_id = request.getParameter("cid");
	content_date = request.getParameter("cdate");
	String query = "location.href='logout.jsp?cid=" + content_id + "&cdate=" + content_date + "'";

	Connection conn = null;
	PreparedStatement stmt = null;
	try {
		Class.forName("org.sqlite.JDBC");
		conn = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		String sql_s = "select * from content_list where CONTENT_ID='"+content_id+"'";
		stmt = conn.prepareStatement(sql_s);
		ResultSet rs_s = stmt.executeQuery();
		if(rs_s.next()) {
			ctimestart = rs_s.getString("CONTENT_TIME_START");
			ctimeend = rs_s.getString("CONTENT_TIME_END");
			ctimeleft = rs_s.getString("CONTENT_TIME_LEFT");
		}
	}
	finally {
		if(stmt != null) try{stmt.close();} catch(SQLException sqle){}
		if(conn != null) try{conn.close();} catch(SQLException sqle){}
	}
	// 현재 날짜와 일정 날짜를 비교해 같지 않으면 에러 메시지 출력
	java.util.Date now = new java.util.Date();
	SimpleDateFormat nowDate = new SimpleDateFormat("yyyy-MM-dd HH:mm");
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
	// 현재 시간
	cal.setTime(now);
	String nT = nowTime.format(cal.getTime());
	
	// 날짜가 다를 경우 에러 메시지 출력
	if(nowDate.format(now).indexOf(content_date) == -1) {
		out.println("QR코드를 다시 스캔해주세요.");
		return;
	}
	// 시작시간보다 빠르거나 종료시간보다 늦은 경우 에러 메시지 출력
	if(nT.compareTo(time) < 0 || nT.compareTo(ctimeend) > 0) {
		out.println("해당 일정의 시간이 아닙니다. " + time + "부터 " + ctimeend + "까지 출석 가능합니다.");
		return;
	}
	
	Connection con = null;
	PreparedStatement stmt_insert = null, stmt_select_content = null, stmt_select_item = null, stmt_update = null;
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		String sql_insert = "insert into content_member_list values(?,?,?,?,?)";
		stmt_insert = con.prepareStatement(sql_insert);
			
		// content_id를 이용해 content_list로부터 일정명, 타입정보를 받아옴
		String sql_select_content = "select * from content_list where CONTENT_ID='"+content_id+"'";	
		stmt_select_content = con.prepareStatement(sql_select_content);
		ResultSet rs_select_content = stmt_select_content.executeQuery();
		String content_name ="", content_type ="";
		if(rs_select_content.next()) {
			content_name = rs_select_content.getString("CONTENT_NAME");
			content_type = rs_select_content.getString("CONTENT_TYPE");
		}
		
		// 자유 형식일 경우
		if(content_type.equals("free")) {
			stmt_insert.setString(1, content_id);
			stmt_insert.setString(2, content_date);
			stmt_insert.setString(3, id);
			stmt_insert.setString(4, name);
			stmt_insert.setString(5, nowDate.format(now));
			stmt_insert.executeUpdate();
		}
		// 신청 형식일 경우
		else {
			String sql_select_item = "select * from content_member_list where CONTENT_ID='"+content_id+"' and CONTENT_DATE='"+content_date+"' and MEMBER_ID='"+id+"' and MEMBER_NAME='"+name+"'";
			stmt_select_item = con.prepareStatement(sql_select_item);
			ResultSet rs_select_item = stmt_select_item.executeQuery();
			// 입력한 정보가 해당 명단에 있을 경우
			if(rs_select_item.next()) {
				// 출석을 아직 하지 않은 상태일 경우
				if(rs_select_item.getString("ATTEND").equals("X")) {
					String sql_update = "update content_member_list set ATTEND='"+nowDate.format(now)+"' where CONTENT_DATE='"+content_date+"' and MEMBER_ID='"+id+"' and MEMBER_NAME='"+name+"' and ATTEND='X'";
					stmt_update = con.prepareStatement(sql_update);
					stmt_update.executeUpdate();
				}
				// 이미 출석이 완료된 상태일 경우
				else {
					out.println(name + "님 이미 출석확인 되었습니다.");
					%>
						<br><input type="button" value="정보 재입력" onclick="<%=query%>">
					<%
					return;
				}
			}
			// 입력된 정보가 해당 명단에 없거나 일치하지 않을 경우
			else {
				out.println("id: " + id);
				out.println("name: " + name);
				out.println("입력하신 정보를 다시 확인해주세요.");
				%>
					<br><input type="button" value="정보 재입력" onclick="<%=query%>">
				<%
				return;
			}
		}
		out.println("" + name + " 님 " + content_date + "일 " + content_name + " 일정 <br>출석 완료되었습니다.");	
		%>
			<input type="button" value="정보 재입력" onclick="<%=query%>">
		<%
	}
	catch(SQLException se) {
		// 자유 참가 형식에서 출석되어있는 사번으로 다시 출석할 때
		if(se.toString().contains("ID")) {
			out.println("이미 출석확인 되었습니다.");
		%>
			<input type="button" value="정보 재입력" onclick="<%=query%>">
		<%
		}
		else System.out.println("SQLException_put.jsp: " + se.getMessage());
	}
	catch(Exception e) {
		System.out.println("Exception_put.jsp: " + e.getMessage());
	}
	finally {
		if(stmt_insert != null) 		try{stmt_insert.close();} catch(SQLException sqle){}
		if(stmt_select_content != null) try{stmt_select_content.close();} catch(SQLException sqle){}
		if(stmt_select_item != null) 	try{stmt_select_item.close();} catch(SQLException sqle){}
		if(stmt_update != null) 		try{stmt_update.close();} catch(SQLException sqle){}
		if(con != null) try{con.close();} catch(SQLException sqle){}
	}
%>	
</div>
</div>
</body>
</html>