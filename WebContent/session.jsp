<!--
	세션에서 사원정보를 put.jsp로 넘겨주게 됨 
	출석 정보 유지 체크박스에 체크했단면 사원정보를 쿠키에 저장
 -->
<%@page import="org.apache.jasper.tagplugins.jstl.core.Redirect"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="css/style.css">
<title>session page</title>
</head>
<body>
<div class="center">
<span class="top"></span>
<%
	request.setCharacterEncoding("UTF-8");
	String cid = "", id = "", name = "", cdate = "", ctype="", loginchk="";
	cid = request.getParameter("content_id");
	id = request.getParameter("txtID");
	name = request.getParameter("txtNAME");
	cdate = request.getParameter("content_date");
	ctype = request.getParameter("content_type");
	loginchk = request.getParameter("loginchk");	// 출석 정보 유지 체크박스 - 체크했다면 true
	
	boolean flag = false;
	String name_encode = URLEncoder.encode(name, "UTF-8");
	session.setAttribute("id", id);
	session.setAttribute("name", name_encode);
	
	// 자유 타입이면 확인 작업 없이 진행
	if(ctype.equals("free")) {
		if(loginchk != null) {
			Cookie cookie = new Cookie("id", id);
			cookie.setMaxAge(365*24*60*60);
			cookie.setPath("/");
			response.addCookie(cookie);

			Cookie cookieN = new Cookie("name", name_encode);
			cookieN.setMaxAge(365*24*60*60);
			cookieN.setPath("/");
			response.addCookie(cookieN);
		}
		response.sendRedirect("put.jsp?cid=" + cid + "&cdate=" + cdate);
	}
	// 신청 타입이면 확인 작업 필요
	else {
		Connection con = null;
		PreparedStatement stmt = null;
		try {
			Class.forName("org.sqlite.JDBC");
			con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
			String sql = "select * from content_member_list where CONTENT_ID='"+cid+"' and CONTENT_DATE='"+cdate+"' and MEMBER_ID='"+id+"' and MEMBER_NAME='"+name+"'";
			stmt = con.prepareStatement(sql);
			ResultSet rs = stmt.executeQuery();
			if(rs.next()) {
				if(loginchk != null) {
					Cookie cookie = new Cookie("id", id);
					cookie.setMaxAge(365*24*60*60);
					cookie.setPath("/");
					response.addCookie(cookie);
					
					Cookie cookieN = new Cookie("name", name_encode);
					cookieN.setMaxAge(365*24*60*60);
					cookieN.setPath("/");
					response.addCookie(cookieN);
				}
				flag = true;
			}
			else {
				out.println("입력하신 정보를 다시 확인해주세요.");
			}
		}
		catch(SQLException se) {
			System.out.println("SQLException_session.jsp: " + se.getMessage());
		}
		catch(Exception e) {
			System.out.println("Exception_session.jsp: " + e.getMessage());
		}
		finally {
			if(stmt != null) try{stmt.close();} catch(SQLException sqle){}
			if(con != null)  try{con.close();} catch(SQLException sqle){}
		}
	}
	if(flag) response.sendRedirect("put.jsp?cid=" + cid + "&cdate=" + cdate);
%>
</div>
</body>
</html>