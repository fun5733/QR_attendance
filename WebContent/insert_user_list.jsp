<!-- 
	신청 참가의 경우 입력받은 참가 명단의 정보를 make_new_content.jsp로부터 전달받음
	전달받은 정보를 DB(content_member_list)에 넣음
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
<title>insert user list</title>
</head>
<body>
<%
	request.setCharacterEncoding("UTF-8");

	// 참가 명단
	String[] values = request.getParameterValues("subject");
	// 일정 날짜 목록
	String cdatestart = request.getParameter("cdatestart");
	String cdateend = request.getParameter("cdateend");	
	String cloginid = "";
	int cid = 0;
	cid = Integer.parseInt(request.getParameter("cid"));
	cloginid = request.getParameter("cloginid");
	
	// 시작일과 종료일 사이의 기간을 목록으로 만들기 위한 부분
	DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
	Calendar cal = Calendar.getInstance();
	java.util.Date startDate = df.parse(cdatestart);
	java.util.Date endDate = df.parse(cdateend);
	long diff = (endDate.getTime() - startDate.getTime()) / (24 * 60 * 60 * 1000);
	Integer days = (int)(long)diff + 1;
	cal.setTime(startDate);
	
	Connection con = null;
	PreparedStatement stmt = null;
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		// (사원 수) X (시작일~종료일 날짜 수) 만큼의 레코드 insert
		while(true) {	
			for(int i=0; i<values.length; i=i+2) {
				String sql = "insert into content_member_list values(?,?,?,?,?)";
				stmt = con.prepareStatement(sql);
				stmt.setInt(1, cid);
				stmt.setString(2, df.format(cal.getTime()));
				stmt.setString(3, values[i]);
				stmt.setString(4, values[i+1]);
				stmt.setString(5, "X");
				stmt.executeUpdate();
			}
			// 종료일이 되면 반복문 탈출
			if(df.format(cal.getTime()).equals(cdateend)) break;
			cal.add(Calendar.DATE, 1); // 날짜 1 증가
		}		
	} 
	catch(Exception e) {
		e.printStackTrace();
	}
	finally {
		if(stmt != null) try{stmt.close();} catch(SQLException sqle){}
		if(con != null) try{con.close();} catch(SQLException sqle){}
	}
	// 작업이 끝나면 일정 리스트 페이지로 돌아감
	response.sendRedirect("content_list.jsp?loginID=" + cloginid);
%>	
</body>
</html>