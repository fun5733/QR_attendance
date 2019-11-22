<!-- 
	login.jsp에서 전달받은 사번으로 등록된 일정들을 표시
	각 일정의 출석 명단, QR코드 확인, 리스트에 있는 일정을 삭제하거나 새로운 일정 등록 가능 
 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import = "java.sql.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>content_list page</title>
<meta charset="utf-8" />
<link rel="stylesheet" href="css/style.css">
<style>
	form { display:inline; }
</style>
<script type="text/javascript" src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script type="text/javascript">
// url 내부의 쿼리문으로부터 정보를 얻기 위한 함수
function getParameterByName(name) {
	name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}
var paramIndex = getParameterByName('index');
// index 정보를 url 파라미터에서 받아오면 창이 열림과 동시에 해당 버튼 자동 클릭
$(document).ready(function() {
	$("#" + paramIndex).get(0).click();
});
// ajax를 이용해 명단 보기가 클릭되면 view_list.jsp에서 갱신된 테이블 내용을 받아 화면에 표시
function setCID(id, i) {
	callAjax(id, i);
}
function callAjax(value, i){	
	$.ajax({
		type: "post",
		async: false,
		url : "./view_list.jsp",
		data: {
			content_id : value,
			index : i,
		},
		success: whenSuccess,
		error: whenError
	});
}
function whenSuccess(resdata){
	document.getElementById("ajaxReturn").style = "display:vidible";
	$("#ajaxReturn").html(resdata);
	System.out.println(resdata);
}
function whenError(){
	alert("Error");
}
// 일정 삭제 버튼을 눌렀을 때 물어보는 알림창 표시
function deletePage(cid, cloginid) {
	if(confirm("삭제하시겠습니까?") == true) {
		location.href = "delete_content.jsp?content_id=" + cid + "&content_loginid=" + cloginid;
	}
}
//셀렉트 박스 선택값이 바뀔 때 일정 리스트를 해당 월의 명단만 표시
function change_c(){
	var selectBox = document.getElementById("id-codes-c");
	var selectedHTML = selectBox.options[selectBox.selectedIndex].innerHTML;
	var tb = document.getElementById("cb");

	// 월 비교를 위해 형식을 같게 만들어줌
	if(selectedHTML.length == 2) selectedHTML = "0" + selectedHTML;
	
	selectedHTML = selectedHTML.substring(0, 2);
	document.getElementById("ajaxReturn").style = "display:none";
	
	for(var i=1; i<cb.rows.length; i++) {
		var temp = cb.rows[i].cells[1].innerHTML.substring(5, 7);
		if(selectedHTML == "0전") {
			cb.rows[i].style = "display:visible";
		}
		else if(temp == selectedHTML) {
			cb.rows[i].style = "display:visible";
		}
		else {
			cb.rows[i].style = "display:none";
		}
	}
}
</script>
</head>
<body>
<%
	Connection con = null;
	PreparedStatement stmt = null;
	String loginID = "", index = "";
	loginID = request.getParameter("loginID");
	index = request.getParameter("index");
%>
<div class="center">
<div class="select">
	<h1>일정 리스트</h1>
	<form action="new_content.jsp" method="post">
		<input name="loginID" value="<%=loginID%>" type="hidden">
		<input type="submit" value="새 일정 추가" style="float:right">
	</form>
	<form action="login.jsp">
		<input type="submit" value="로그인 화면으로"  style="float:right">
	</form><br>
	
	<select id="id-codes-c" name="codes-c" onchange="change_c()">
		<option>전체</option>
<%
	for(int i=1; i<=12; i++) {
%>
		<option><%=i%>월</option>
<%
	}
%>
	</select>
</div>
<%
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		String sql = "select * from content_list";
		// 로그인 아이디가 관리자용이면 관리자용으로 접속 -> 모든 일정이 표시됨
		if(!loginID.equals("9999999")) {	// 현재 관리자 사번 : 9999999">
			sql += " where CONTENT_LOGINID='"+loginID+"'";
			out.println("사번 : " + loginID + " 님의 일정 리스트");	
		}
		else out.println("관리자용");
		
		// 날짜, 시간 순으로 내림차순 정렬
		sql += " order by CONTENT_DATE_START desc, CONTENT_TIME_START desc";
		stmt = con.prepareStatement(sql);
		ResultSet rs = stmt.executeQuery();
		String cid="";
%>
<div class="content">
	<table border="1" id="cb">
		<thead bgcolor="#CCCC99">
		<tr>
			<td>일정명</td>
			<td>기간</td>
			<td>시간</td>
			<td>주최자</td>
			<td>명단</td>
			<td>QR코드</td>
			<td>삭제</td>
		</tr>
		</thead>
<%
		int i = 0;	// 리스트에서 몇 번째 일정인지 저장할 변수
		// 반복문을 돌면서 일정 리스트 출력
		while(rs.next()) {
			cid = rs.getString("CONTENT_ID");
%>
		<tr>
			<td><%=rs.getString("CONTENT_NAME") %></td> 
<%
			// 하루 일정일 경우
			if(rs.getString("CONTENT_DATE_START").equals(rs.getString("CONTENT_DATE_END"))) {
%>
			<td><%=rs.getString("CONTENT_DATE_START") %></td>
<%
			}
			//며칠 일정일 경우
			else {
%>
			<td><%=rs.getString("CONTENT_DATE_START") %> ~ <br><%=rs.getString("CONTENT_DATE_END") %></td>
<%
			}
%>
			<td><%=rs.getString("CONTENT_TIME_START") %> ~ <%=rs.getString("CONTENT_TIME_END") %></td>
			<td><%=rs.getString("CONTENT_HOST") %></td>
			<td><a href="javascript:setCID(<%=cid%>, <%=i%>)" id="<%=i%>">보기</a></td>	<!-- 클릭하면 ajax로 값을 넘겨 화면을 부분적(div id=ajaxReturn)으로 갱신되게 함 -->
			<td>
				<form action="view_qr.jsp" method="post">
					<input name="content_id" value="<%=rs.getString("CONTENT_ID") %>" type="hidden">
					<input type="submit" value="보기">
				</form>
			</td>
			<td>
				<button type="button" onclick="deletePage(<%=rs.getString("CONTENT_ID") %>, <%=rs.getString("CONTENT_LOGINID") %>)">X</button>
			</td>
		</tr>			
<%	
			i++;
		}
	}
	catch(SQLException se) {
		System.out.println("SQL Exception_content_list.jsp: " + se.getMessage());
	}
	catch(Exception e) {
		System.out.println("Exception_content_list.jsp: " + e.getMessage());
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
	</table>
</div>
<!-- view_list.jsp에서 갱신된 화면을 표시할 영역 -->
<div id="ajaxReturn"></div>
</div>
</body>
</html>