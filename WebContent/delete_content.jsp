<!-- 
	리스트에 등록된 일정을 리스트에서 삭제
		-> 일정을 등록한 사번을 바꿔서 보이지 않게 될 뿐, 실제로 데이터가 없어지는 것은 아님
 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%
	request.setCharacterEncoding("UTF-8");
	String cid = request.getParameter("content_id");
	String cloginid = request.getParameter("content_loginid");
	
	Connection con = null;
	PreparedStatement stmt = null;
	
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		// delete하는 게 아니라 login_id를 9999999(배정되지 않을 사번)로 바꿔서 해당 일정이 더 이상 리스트에 표시되지 않게 됨
		String sql = "update content_list set CONTENT_LOGINID=9999999 where CONTENT_ID='"+cid+"'";
		stmt = con.prepareStatement(sql);
		stmt.executeUpdate();
	}
	catch(SQLException se) {
		System.out.println("SQL Exception: " + se.getMessage());
	}
	finally {
		if(stmt!=null) try{stmt.close();} catch(SQLException sqle){}
		if(con!=null) try{con.close();} catch(SQLException sqle){}
	}	
	// 작업이 끝난 후 다시 일정 리스트 페이지 표시-> 깜박거림 후 삭제되어있음
	response.sendRedirect("content_list.jsp?loginID=" + cloginid);
%>