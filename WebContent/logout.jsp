<!-- 
	��Ű�� ����� ��������� ����
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
	
	long key1 = 1759, key2 = 29, key3 = 19700101;	// ��ȣŰ
	String temp = cdate.toString().replace("-",""); // 2019-11-08 --> 20191108
	long val = ((Long.parseLong(temp) + key3) * key1 + Long.parseLong(cid)) * key2; // �캯�� ���� ���� �����Ǵ� ��ȣ��
	
	session.invalidate();
	//�α��� ���� ��Ű ����
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
	// �ش� �⼮ �������� ���ư�
	response.sendRedirect("attendance.jsp?param=" + val);
%>
</body>
</html>