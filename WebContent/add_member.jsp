<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.text.*" %>
<%
	String id="", name="", index="", cloginid="", cdatestart="", cdateend="";
	int cid = 0;
	id = request.getParameter("txtID");
	name = request.getParameter("txtNAME");
	index = request.getParameter("index");
	cloginid = request.getParameter("cloginid");
	cdatestart = request.getParameter("cdatestart");
	cdateend = request.getParameter("cdateend");
	cid = Integer.parseInt(request.getParameter("cid"));
	
	Connection con = null;
	PreparedStatement stmt = null;
	PreparedStatement stmt_check = null;
	
	// �����ϰ� ������ ������ �Ⱓ�� ������� ����� ���� �κ�
	DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
	Calendar cal = Calendar.getInstance();
	java.util.Date startDate = df.parse(cdatestart);
	java.util.Date endDate = df.parse(cdateend);
	long diff = (endDate.getTime() - startDate.getTime()) / (24 * 60 * 60 * 1000);
	Integer days = (int)(long)diff + 1;
	cal.setTime(startDate);
	
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		String sql_check = "select * from content_member_list where MEMBER_ID = '"+id+"'";
		stmt_check = con.prepareStatement(sql_check);
		ResultSet rs_check = stmt_check.executeQuery();
			
		// �Է¹��� ����� ������ ���̺� insert 
		String sql = "insert into content_member_list values(?,?,?,?,?)";
		while(true) {	
			stmt = con.prepareStatement(sql);
			stmt.setInt(1, cid);
			stmt.setString(2, df.format(cal.getTime()));
			stmt.setString(3, id);
			stmt.setString(4, name);
			stmt.setString(5, "X");
			stmt.executeUpdate();
			
			// ��¥�� 1�� �������� �������� �� ������ �ݺ�
			if(df.format(cal.getTime()).equals(cdateend)) break;
			cal.add(Calendar.DATE, 1); // ��¥ 1 ����
		}
	}
	finally {
		try {
			if(con!=null) con.close();
			if(stmt!=null) stmt.close();
		}
		catch(SQLException se) {
			if(se.toString().contains("ID")) out.println("�̹� �⼮Ȯ�� �Ǿ����ϴ�.");
			else System.out.println("SQLException_add_member.jsp : " + se.getMessage());
		}
		catch(Exception e) {
			System.out.println("Exception_add_member.jsp : " + e.getMessage());
		}
	}	
	// �۾��� ���� �� �ٽ� ���� ����Ʈ ������ ǥ��
	response.sendRedirect("content_list.jsp?loginID=" + cloginid + "&index=" + index);
%>