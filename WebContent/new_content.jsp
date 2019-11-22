<!-- 
	새로운 일정을 등록하는 버튼을 누르면 오게 되는 페이지
	새로운 일정의 정보를 입력받아서 make_new_content.jsp로 전달
 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>new content page</title>
<link rel="stylesheet" href="css/style.css">
<style>
	div { zoom : 1.1;}
</style>
<% String loginID = request.getParameter("loginID"); %>
<script>
// 유형 셀렉트박스(설명회, 교육, 회의, 기타)에 변화가 생기면 그 값을 input값에 집어넣음
function styleChange() {
	var style = document.getElementById("style");
	var style_selected = style.options[style.selectedIndex].innerHTML;
	document.forms["myForm"]["txtCSTYLE"].value = style_selected;
}
function fn_press(event, type) {
	if(type == "numbers") {
		if(event.keyCode < 48 || event.keyCode > 57) {
			alert("숫자만 입력할 수 있습니다");
			return false;
		}
	}
}
function inputTimeColon(time) {
	if(time.value != time.value.replace(/[\ㄱ-ㅎ ㅏ-ㅣ 가-힣]/g, '')) {
		alert("숫자만 입력할 수 있습니다");
		time.value = time.value.replace(/[\ㄱ-ㅎ ㅏ-ㅣ 가-힣]/g, '');
		return false;
	}
	// 기존에 들어가 있는 (:)을 제거 
	var replaceTime = time.value.replace(/\:/g, ""); 
	// 글자수가 4개일때만 동작하게 조건 명시 
	if(replaceTime.length == 4) { 
		// 시간 추출 
		var hours = replaceTime.substring(0, 2); 
		// 분 추출 
		var minute = replaceTime.substring(2, 4); 
		if(hours + minute > 2400) {
			time.value = "00:00"; 
			return false; 
		} 
		if(hours + minute < 0) {  
			time.value = "00:00"; 
			return false; 
		} 
		if(minute > 60) {
			time.value = hours + ":00"; 
			return false; 
		} 
		// 시간을 완성하고 반환한다. 
		time.value = hours + ":" + minute; 
	} 
} 
// 시작일이 과거인지 판별
function check_fast() {
	var now = new Date().toISOString().substring(0, 10);
	var date = document.forms["myForm"]["txtCDATE_START"].value;
	var fast = document.getElementById("fast");
	if(date.length >= 8) {
		// 과거라면 입력창 옆에 공간에 과거라는 것을 텍스트로 표시
		if(now > date) fast.innerHTML = "과거";
		else fast.innerHTML = "";
	}
}
function check_time() {
	var time = document.forms["myForm"]["txtCTIME_START"].value;
	var hour = parseInt(time.substring(0, 2));
	var min = parseInt(time.substring(3, 5));
	var selectBox = document.getElementById("left_time");
	var left_time = selectBox.options[selectBox.selectedIndex].innerHTML;
	document.forms["myForm"]["txtCTIME_LEFT"].value = left_time; 
	
	// 30/60/90 분에 맞게 시간 설정
	if(left_time == "30") {
		min -= 30;
		if(min < 0) {
			hour -= 1;
			if(hour < 0) { hour = 0; min = 0; }
			else { min = 60 + min; }
		}
	}
	else if(left_time == "60") {
		hour -= 1;
		if(hour < 0) { hour = 0; min = 0; }
	}
	else {
		if(min < 0) {
			hour -= 1;
			if(hour < 0) { hour = 0; min = 0; }
			else { min = 60 + min; }
		}
		hour -= 1;
		if(hour < 0) { hour = 0; min = 0; }
	}
	if(hour < 10) hour = "0" + hour;
	if(min < 10) min = "0" + min;
	
	var time_notice = document.getElementById("time_notice");
	if(time.length >= 4) { 
		document.getElementById("time_notice").innerHTML = hour + ":" + min + " 부터 출석 가능";	
	}
}
function validateForm() {
	var cid = document.forms["myForm"]["txtCID"].value;
	var cname = document.forms["myForm"]["txtCNAME"].value;
	var chost = document.forms["myForm"]["txtCHOST"].value;
	var cdatestart = document.forms["myForm"]["txtCDATE_START"].value;
	var cdateend = document.forms["myForm"]["txtCDATE_END"].value;
	var ctimestart = document.forms["myForm"]["txtCTIME_START"].value;
	var ctimeend = document.forms["myForm"]["txtCTIME_END"].value;

	if(cname == "" || cid == ""  || chost == "" || cdatestart == "" || ctimestart == "" || ctimeend == "") {
		alert("빈 칸을 채워주세요.");
		return false;
	}
	else if(cdateend == "") {
		document.forms["myForm"]["txtCDATE_END"].value = cdatestart;
	}
	else if(cdateend < cdatestart) {
		alert("종료일이 시작일보다 빠르게 입력되어있습니다.");
		document.forms["myForm"]["txtCDATE_END"].value = "";
		return false;
	}
	if(ctimeend < ctimestart) {
		alert("종료시간이 시작시간보다 빠르게 입력되어있습니다.");
		document.forms["myForm"]["txtCTIME_END"].value = "";
		return false;
	}
	return true;
}
</script>
</head>
<body>
<%
	Connection con = null;
	PreparedStatement stmt = null;
	int cid = 0;
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");
		String sql = "select * from content_list";
		stmt = con.prepareStatement(sql);
		ResultSet rs = stmt.executeQuery();
		// content_id를 자동생성 -> 현재 DB 내의 가장 큰 content_id + 1값
		while(rs.next()) {
			if(cid < rs.getInt("CONTENT_ID")) cid = rs.getInt("CONTENT_ID");
		}
		cid++;
	}
	catch(SQLException se) {
		System.out.println("SQL Exception_new_content.jsp: " + se.getMessage());
	}
	catch(Exception e) {
		System.out.println("Exception_new_content.jsp: " + e.getMessage());
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
<div class="center">
<span class="top" ></span>
<div class="content" >
<form name="myForm" action="make_new_content.jsp" method="post" onsubmit="return validateForm()">
	<span class="input">일정명</span> 	<input type="text" class="newData" name="txtCNAME">
		<span class="input">
		<select id="style" onchange="styleChange()">
			<option>설명회</option><option>교육</option><option>회의</option><option>기타</option>
		</select>
		</span><br>
		<input type="hidden" name="txtCSTYLE" value="설명회">
	<input type=hidden name="txtCID" value="<%=cid%>">					
	<span class="input">시작일</span>  <input type="date" class="newData" name="txtCDATE_START" onblur="check_fast()"><span class="input" id="fast"></span><br>
	<span class="input">종료일</span>  <input type="date" class="newData" name="txtCDATE_END"><span class="input"></span><br>
	<span class="input">시작시간</span>  	<input type="time" class="newDataTime" name="txtCTIME_START" onblur="check_time()"><span class="input"></span><br>
	<span class="input">종료시간</span>	<input type="time" class="newDataTime" name="txtCTIME_END" ><span class="input"></span><br>
	<span class="input">출석가능시간</span>	시작시간
		<select id="left_time" onchange="check_time()">
			<option>30</option><option>60</option><option>90</option>
		</select>분 전부터<span class="input"></span><br>
		<input type="hidden" name="txtCTIME_LEFT" value="30">
	<span class="input">주최자</span> 	<input type="text" class="newData" name="txtCHOST" ><span class="input"></span><br>
	<span class="input">타입</span>  	<input type="radio" name="txtCTYPE" value="free" checked="checked">자유참가
		 							<input type="radio" name="txtCTYPE" value="apply">신청참가
	<input type="hidden" name="txtCLOGINID" value="<%=loginID %>"><span class="input"></span><br>
	<input type="submit" value="추가">
</form>
</div>
<!-- 언제부터 출석 가능한지 표시 -->	
<p id="time_notice"></p>
</div>
</body>
</html>