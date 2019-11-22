<%-- 
	QR코드 스캔을 통해 참석자가 접속하게 되는 페이지
	param 이라는 암호화된 파라미터에서 content_id와 content_date를 추출
	입력받은 정보를 put.jsp로 전달하게 됨
 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="css/style.css">
<title>attendance page</title>
<script>
function fn_press(event, type) {
	if(type == "numbers") {
		if((event.keyCode < 48 && event.keyCode != 13)|| event.keyCode > 57) {
			alert("숫자만 입력할 수 있습니다");
			return false;
		}
	}
}
function fn_press_han(obj) {
	if(obj.value != obj.value.replace(/[\ㄱ-ㅎ ㅏ-ㅣ 가-힣]/g, '')) {
		alert("숫자만 입력할 수 있습니다");
		obj.value = obj.value.replace(/[\ㄱ-ㅎ ㅏ-ㅣ 가-힣]/g, '');
		return false;
	}
}
function check_key() {
	var char_ASCII = event.keyCode;
	// 특수문자 확인
	if ((char_ASCII>=33 && char_ASCII<=47) || (char_ASCII>=58 && char_ASCII<=64)
	   || (char_ASCII>=91 && char_ASCII<=96) || (char_ASCII>=123 && char_ASCII<=126))
	    return 1;
	else
	    return 0;
}
function specialKey() {
	if(check_key() == 1) {
		event.returnValue = false;
		alert("특수문자는 입력할 수 없습니다");
		return;
	}
}
function validateForm() {
	var userid = document.forms["myForm"]["txtID"].value;
	var username = document.forms["myForm"]["txtNAME"].value;
	if(username == "" || userid == "") {
		alert("빈 칸을 채워주세요");
		return false;
	}
	else if(userid.length != 7) {
		alert("사번은 7자리 숫자입니다");
		return false;
	}
	return true;
}
</script>
</head>
<body>
<div class="center">
<%
	// param decoding code -> param 값으로 content_id, content_date 추출--------
	String cid = "", cdate = "", ctimestart="", ctimeend="", ctimeleft="", content_name ="", content_type ="";
	long key1 = 1759, key2 = 29, key3 = 19700101;
	long param = Long.parseLong(request.getParameter("param"));
	if(param % key2 != 0) {
		out.println("QR코드를 다시 스캔해주세요.");
		return;
	}
	param /= key2;
	long c = param % key1;
	param -= c;
	cdate = (param / key1 - key3) + "";
	if(cdate.length() == 8) {
		cdate = cdate.substring(0,4) + "-" + cdate.substring(4,6) + "-" + cdate.substring(6,8);
	}
	// param 값을 임의로 조작해 접근 시 추출된 content_date가 8자리 안될 시 에러 메시지 출력
	else {
		out.println("QR코드를 다시 스캔해주세요.");
		return;
	}
	cid = ""+c;
	
	// 쿠키 가져오기
	Cookie[] cookies = request.getCookies();
	if(cookies != null) {
		for(Cookie tempCookie : cookies) {
			if(tempCookie.getName().equals("id")) {
				response.sendRedirect("put.jsp?cid=" + cid + "&cdate=" + cdate);
			}
		}
	}
	
	// content_id를 이용해 content_list로부터 일정 정보를 받아옴
	String sql = "select * from content_list where CONTENT_ID='"+cid+"'";
	Connection con = null;
	PreparedStatement stmt = null;		
	
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		stmt = con.prepareStatement(sql);
		ResultSet rs_select_content = stmt.executeQuery();
		if(rs_select_content.next()) {
			content_name = rs_select_content.getString("CONTENT_NAME");
			content_type = rs_select_content.getString("CONTENT_TYPE");
		}
		else {
			out.println("QR코드를 다시 스캔해주세요.");
			return;
		}
	}
	catch(SQLException se) {
		System.out.println("SQLException_attendance.jsp : " + se.getMessage());
	}
	catch(Exception e) {
		System.out.println("Exception_attendance.jsp : " + e.getMessage());
	}
	finally {
		if(stmt != null) try{stmt.close();} catch(SQLException sqle){}
		if(con != null) try{con.close();} catch(SQLException sqle){}
	}
%>
<span class="top"></span>
<h1><%=cdate %><br>
<%=content_name %></h1>
<img src="images/qr_scan.png" width="256px" height="256px">
<span class="content">
<form name="myForm" action="session.jsp" method="post" onsubmit="return validateForm()">
	사번  <input type="text" class="attendData" name="txtID" maxlength="7" onkeypress="return fn_press(event, 'numbers');" onkeyup="fn_press_han(this);" style="ime-mode:Disabled"><br><br>
	이름  <input type="text" class="attendData" name="txtNAME" onkeypress="specialKey()"><br>
	<input type = "checkbox" name="loginchk" value = "true">출석 정보 유지<br>
	<input name="content_id" value="<%= cid %>" type="hidden">
	<input name="content_type" value="<%= content_type %>" type="hidden">
	<input name="content_date" value="<%= cdate %>" type="hidden"><br><br>
	<input type="submit" value="출석" style="width:110px; height:70px;">
</form>	
</span>
<span class="top"></span>
</div>
</body>
</html>