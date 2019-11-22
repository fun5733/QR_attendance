<!-- 
	리스트에 등록된 사원을 리스트에서 삭제
 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%
	request.setCharacterEncoding("UTF-8");
	String id="", cid="", cloginid="", index="";
	id = request.getParameter("id");
	while(id.length() < 7) {
		id = "0" + id;
	}
	cid = request.getParameter("content_id");
	cloginid = request.getParameter("content_loginid");
	index = request.getParameter("index");
	
	Connection con = null;
	PreparedStatement stmt = null;
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		
		String sql = "delete from content_member_list where MEMBER_ID = '"+id+"' and CONTENT_ID = '"+cid+"'";
		stmt = con.prepareStatement(sql);
		stmt.executeUpdate();
	}
	finally {
		try {
			if(con!=null) con.close();
			if(stmt!=null) stmt.close();
		}
		catch(SQLException se) {
			System.out.println("SQL Exception_delete_member.jsp: " + se.getMessage());
		}
	}	
	// 작업이 끝난 후 다시 일정 리스트 페이지 표시-> 깜박거림 후 삭제되어있음
	response.sendRedirect("content_list.jsp?loginID=" + cloginid + "&index=" + index);
%>