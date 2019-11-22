<!-- 
	content_list.jsp에서 클릭된 일정의 출석 명단을 생성,
	ajax를 통해 content_list의 특정 div에서 이를 표시
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
<script type="text/javascript" src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script>
//셀렉트 박스 선택값이 바뀔 때 출석 명단을 해당 날짜의 것으로 교체해서 표시
function change() {
	var selectBox = document.getElementById("id-codes");
	var selectedHTML = selectBox.options[selectBox.selectedIndex].innerHTML;
	var list = document.getElementById("list");
	var intro = document.getElementById("intro");
	var tb = document.getElementById("tb");
	var count = tb.rows.length-1;	// 몇 명 출석인지 카운트할 변수를 명단 전체 인원 수로 초기화
	for(var i=1; i<tb.rows.length; i++) {
		var temp = tb.rows[i].cells[2].innerHTML.substring(0,4) + "-" + tb.rows[i].cells[2].innerHTML.substring(5,7) + "-" + tb.rows[i].cells[2].innerHTML.substring(8,10);
		if(selectedHTML == "전체") {
			intro.style = "display:visible";
			list.style = "display:none";
			tb.rows[i].style = "display:visible";
			document.getElementById("percent").style = "display:visible";
			document.getElementById("t_date").style = "display:none";
			document.getElementById("t_attend").style = "display:none";
			document.getElementById("t_delete").style = "display:visible";
			document.getElementById("count").innerHTML = "";
		}
		else {
			document.getElementById("percent").style = "display:none";
			document.getElementById("t_date").style = "display:visible";
			document.getElementById("t_attend").style = "display:visible";
			document.getElementById("t_delete").style = "display:none";
			list.style = "display:visible";
			intro.style = "display:none";
			
			if(temp != selectedHTML) {
				tb.rows[i].style = "display:none";
				// 전체 수(=count)에서 춝석이 안된 사람 수를 빼면 출석 인원이 나옴
				count--;
			}
			// 선택한 날짜의 출석 명단을 표시
			else {
				tb.rows[i].style = "display:visible";
				// 전체 수(=count)에서 춝석이 안된 사람 수를 빼면 출석 인원이 나옴
				if(tb.rows[i].cells[3].innerHTML == "X") count--;
			}
			document.getElementById("count").innerHTML = count + "명 출석";
		}
	}
}
// 명단에 사원정보를 추가 등록
function add() {
	var addForm = document.getElementById("addForm");
	var addButton = document.getElementById("addButton");
	addForm.style = "display:visible";
	addButton.style = "display:none";
}
// 추가 버튼을 눌렀다가 다시 취소할 때
function cancel() {
	var addForm = document.getElementById("addForm");
	var addButton = document.getElementById("addButton");
	addForm.style = "display:none";
	addButton.style = "display:visible";
	document.forms["addForm"]["txtID"].value = "";
	document.forms["addForm"]["txtNAME"].value = "";
}
//삭제 버튼을 눌렀을 때 물어보는 알림창 표시
function deleteMember(member_id, cid, cloginid, index, name) {
	if(confirm(name + "님을 명단에서 삭제하시겠습니까?") == true) {
		location.href = "delete_member.jsp?id=" + member_id + "&content_loginid=" + cloginid + "&content_id=" + cid + "&index=" + index;
	}
}
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
	var id = document.forms["addForm"]["txtID"].value;
	var name = document.forms["addForm"]["txtNAME"].value;
	var tb = document.getElementById("tb");
	if(name == "" || id == "") {
		alert("빈 칸을 채워주세요.");
		return false;
	}
	else if(id.length != 7) {
		alert("사번은 7자리 숫자입니다");
		return false;
	}
	for(var i=1; i<tb.rows.length; i++) {
		if(tb.rows[i].cells[0].innerHTML == id) {
			alert("중복되는 사원정보가 등록되어있습니다.");
			return false;
		}
	}
	return true;
}
</script>
</head>
<body>
<%
	String date="", content_name="", cdatestart="", cdateend="", cloginid="", ctype="", i="", content_id="", index="", temp="", all="";
	content_id = request.getParameter("content_id");
	index = request.getParameter("index");
	
	Connection con = null;
	PreparedStatement stmt = null;
	PreparedStatement stmt_qr = null;
	PreparedStatement stmt_view = null;
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
			cloginid = rs_qr.getString("CONTENT_LOGINID");
			ctype = rs_qr.getString("CONTENT_TYPE");
		}
		
		// 기간 중 날짜 목록 생성
		DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		Calendar cal = Calendar.getInstance();
		java.util.Date startDate = df.parse(cdatestart);
		java.util.Date endDate = df.parse(cdateend);
		long diff = (endDate.getTime() - startDate.getTime()) / (24 * 60 * 60 * 1000);
		Integer days = (int)(long)diff + 1;
		cal.setTime(startDate);
%>
<br>
<div class="select">
	<span style="float:right; padding-right:10%"><%=content_name %> 명단</span>
	<select id="id-codes" onchange="change()">
		<option>전체</option>	
<%
		while(true) {	
%>
		<option><%=df.format(cal.getTime()) %></option>
<%	
			//종료일까지 증가하면 반복문 탈출
			if(df.format(cal.getTime()).equals(cdateend)) break;
			cal.add(Calendar.DATE, 1); // 날짜 1 증가
		}
%>	
	</select>
<%
	// 신청 일정일 경우 추가 버튼 표시
		if(ctype.equals("apply")) {
%>
		<button type="button" id="addButton" onclick="add()">추가</button>
<%
		}
%>
<form id="addForm" action="add_member.jsp" method="post" onsubmit="return validateForm()" style="display:none">
	<button type="button" onclick="cancel()">취소</button>
	사번  <input type="text" class="attendData" name="txtID" maxlength="7" onkeypress="return fn_press(event, 'numbers');" onkeyup="fn_press_han(this);" style="ime-mode:Disabled">
	이름  <input type="text" class="attendData" name="txtNAME" onkeypress="specialKey()">
	<input type="hidden" name="cdatestart" value="<%=cdatestart %>">
	<input type="hidden" name="cdateend" value="<%=cdateend %>">
	<input type="hidden" name="cloginid" value="<%=cloginid %>">
	<input type="hidden" name="cid" value="<%=content_id %>">
	<input type="hidden" name="index" value="<%=index %>">
	<input type="submit" id="addMember" value="등록">
</form>
</div>
<div class="member">
<table border="1" id="tb">
	<thead bgcolor="#CCCC99">
	<tr>
		<th>사번</th>
		<th>이름</th>
		<th id="t_date" style="display:none">날짜</th>
		<th id="t_attend" style="display:none">출석</th>
		<th id="percent">출석/전체</th>
		<th id="t_delete">삭제</th>
	</tr>
	</thead>
	<!-- '전체'외의 날짜를 선택했을 때 나오는 테이블 - 날짜별로 개개인의 출석 현황을 알 수 있음 -->
	<tbody id="list" style="display:none">
<%
		while(rs.next()) {
%>
	<tr>
		<td><%=rs.getString("MEMBER_ID") %></td> 
		<td><%=rs.getString("MEMBER_NAME") %></td>
		<td><%=rs.getString("CONTENT_DATE") %></td>
		<td><%=rs.getString("ATTEND") %></td>
	</tr>			
<%	
		}
		String sql_view = "select * from content_member_list where CONTENT_DATE = '"+cdatestart+"' and CONTENT_ID = '"+content_id+"'";
		stmt_view = con.prepareStatement(sql_view);
		ResultSet rs_view = stmt_view.executeQuery();	
		while(rs_view.next()) {
			String sql_count = "select count(*) from content_member_list where CONTENT_ID = '"+content_id+"' and MEMBER_ID = '"+rs_view.getString("MEMBER_ID")+"' and ATTEND <> 'X'";
			String sql_all = "select count(*) from content_member_list where CONTENT_ID = '"+content_id+"' and MEMBER_ID = '"+rs_view.getString("MEMBER_ID")+"'";
			int temp_count = 0;
			int all_count = 0;
			
			// 출석 횟수 카운트
			PreparedStatement stmt_count = null;
			stmt_count = con.prepareStatement(sql_count);
			ResultSet rs_count = stmt_count.executeQuery();
			if(rs_count.next()) {
				temp_count = rs_count.getInt(1);
			}
			temp = temp_count+"";
			
			// 전체 날짜 수 카운트
			PreparedStatement stmt_all = null;
			stmt_all = con.prepareStatement(sql_all);
			ResultSet rs_all = stmt_all.executeQuery();
			if(rs_all.next()) {
				all_count = rs_all.getInt(1);
			}
			all = all_count+"";
%>
	</tbody>
	<!-- '전체' 선택했을 때 나오는 테이블 - 개개인의 전체적인 출석 현황을 알 수 있음 -->
	<tbody id="intro" style="display:visible">
	<tr>
		<td><%=rs_view.getString("MEMBER_ID") %></td> 
		<td><%=rs_view.getString("MEMBER_NAME") %></td>
		<td><%=temp%> / <%=all%></td>
		<td><button type="button" onclick="deleteMember(<%=rs_view.getInt("MEMBER_ID")%>, <%=content_id%>, <%=cloginid%>, <%=index%>, '<%=rs_view.getString("MEMBER_NAME") %>')">X</button></td>
	</tr>
<%
		}
%>
	</tbody>
</table>
</div>
<!-- 몇 명 출석했는지를 표시 -->
<p id="count"></p>
<%
	}
	catch(SQLException se) {
		System.out.println("SQL Exception_view_list.jsp: " + se.getMessage());
	}
	catch(Exception e) {
		System.out.println("Exception_view_list.jsp: " + e.getMessage());
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