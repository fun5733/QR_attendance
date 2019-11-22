<!-- 
	쿠키에 저장된 사원정보를 삭제
 -->
<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>logout page</title>
</head>
<body>
<%
	String cid="", cdate="";
	cid = request.getParameter("cid");
	cdate = request.getParameter("cdate");
	
	long key1 = 1759, key2 = 29, key3 = 19700101;	// 암호키
	String temp = cdate.toString().replace("-",""); // 2019-11-08 --> 20191108
	long val = ((Long.parseLong(temp) + key3) * key1 + Long.parseLong(cid)) * key2; // 우변의 식을 통해 생성되는 암호값
	
	session.invalidate();
	//로그인 관련 쿠키 삭제
	Cookie[] cookies = request.getCookies();
	if(cookies != null) {
		for(Cookie tempCookie : cookies) {
			if(tempCookie.getName().equals("id") || tempCookie.getName().equals("name")) {
				tempCookie.setMaxAge(0);
				tempCookie.setPath("/");
				response.addCookie(tempCookie);
			}
		}
	}
	// 해당 출석 페이지로 돌아감
	response.sendRedirect("attendance.jsp?param=" + val);
%>
</body>
</html>