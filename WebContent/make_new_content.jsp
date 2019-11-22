<!-- 
	new_content.jsp로부터 새로운 일정의 정보를 전달받아, 이를 토대로 새로운 일정을 DB(content_list 테이블)에 넣음
	새로운 일정이 만들어지면 이에 해당하는 QR코드를 생성
 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.text.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.io.File" %>
<%@ page import = "java.awt.image.BufferedImage, javax.imageio.ImageIO" %>
<%@ page import = "com.google.zxing.qrcode.QRCodeWriter, com.google.zxing.common.BitMatrix, com.google.zxing.BarcodeFormat, com.google.zxing.client.j2se.MatrixToImageWriter" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Make new content page</title>
<link rel="stylesheet" href="css/style.css">
<script language="javascript">
function fn_press(event) {
	if(event.keyCode < 48 || event.keyCode > 57) {
		alert("숫자만 입력할 수 있습니다");
		return false;
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
// 셀렉트 박스에서 어떤 날짜를 선택하는지에 따라 표시되는 QR코드 바뀜
function change(){
	var selectBox = document.getElementById("id-codes");
	var selectedValue = selectBox.options[selectBox.selectedIndex].value;
	var img = "<img src=" + selectedValue + ">";
	document.getElementById("img_out").innerHTML = img;
}
// 명단에 인원 추가
function addItem() {
      var lo_table = document.getElementById("TblAttach");
      var row_index = lo_table.rows.length;      // 테이블(TR) row 개수
      newTr = lo_table.insertRow(row_index);
      newTr.idName = "newTr" + row_index;
 
      newTd=newTr.insertCell(0);
      newTd.innerHTML= "사번";
 
      newTd=newTr.insertCell(1);
      newTd.innerHTML= "<input type=text class = attendData name=subject maxlength=7 onkeypress='return fn_press(event);' onkeyup=fn_press_han(this); style=ime-mode:Disabled>";
      
      newTd=newTr.insertCell(2);
      newTd.innerHTML= "이름";
      
      newTd=newTr.insertCell(3);
      newTd.innerHTML= "<input type=text class = attendData name=subject onkeypress=specialKey()>";
}
//명단에 인원 삭제
function delItem(){
      var lo_table = document.getElementById("TblAttach");
      var row_index = lo_table.rows.length-1;      // 테이블(TR) row 개수
 
      if(row_index > 0) lo_table.deleteRow(row_index);    
}
function validateForm() {
	var inputs = document.getElementsByName('subject');
	var id_pattern = /^\d{7}$/;
	if(inputs.length == 0) {
		alert("최소한 한 개 이상의 행을 입력해주세요.");
		return false;
	}
	for(var i=0; i<inputs.length; i++) {	
		if(inputs[i].value === '') {
			alert("빈 칸을 채워주세요.");
			return false;
		}
		else if(i % 2 == 0 && !id_pattern.test(inputs[i].value)){
			alert("사번은 7자리 숫자입니다.");
			return false;
		}
		for(var j=0; j<i; j++) {
			if(inputs[i].value == inputs[j].value && i % 2 == 0) {
				alert("사번이 중복되는 데이터가 있습니다." );
				return false;
			}
		}	
	}
	return true;
}
</script>
</head>
<body>
<div class="center">
<% 
	String cname="", chost="", ctype="", cloginid="", cdatestart="", cdateend="", dates = "", ctimestart="", ctimeend="", ctimeleft="", cstyle="";
	int cid = 0;
	cid = Integer.parseInt(request.getParameter("txtCID"));
	cname = request.getParameter("txtCNAME");
	chost = request.getParameter("txtCHOST");
	ctype = request.getParameter("txtCTYPE");
	cloginid = request.getParameter("txtCLOGINID");
	cdatestart = request.getParameter("txtCDATE_START");
	cdateend = request.getParameter("txtCDATE_END");
	ctimestart = request.getParameter("txtCTIME_START");
	ctimeend = request.getParameter("txtCTIME_END");
	ctimeleft = request.getParameter("txtCTIME_LEFT");
	cstyle = request.getParameter("txtCSTYLE");
	
	Connection con = null;
	PreparedStatement stmt = null;
	try {
		Class.forName("org.sqlite.JDBC");
		con = DriverManager.getConnection("jdbc:sqlite:../../Users/tmpl/workspace/JSPDB/WebContent/test.db");

		String sql = "insert into content_list values(?,?,?,?,?,?,?,?,?,?,?)";
		stmt = con.prepareStatement(sql);
		stmt.setString(1, cname);
		stmt.setInt(2, cid);
		stmt.setString(3, cdatestart);
		stmt.setString(4, cdateend);
		stmt.setString(5, chost);
		stmt.setString(6, ctype);
		stmt.setString(7, cloginid);
		stmt.setString(8, ctimestart);
		stmt.setString(9, ctimeend);
		stmt.setString(10, ctimeleft);
		stmt.setString(11, cstyle);
		stmt.executeUpdate();
		
		// 자유 참가일 경우
		if(ctype.equals("free")) {
			out.println("" + cname + " 일정 추가 완료");	 
%>
			<form action="content_list.jsp" method="post">
				<input name="loginID" value="<%= cloginid %>" type="hidden">
				<input type="submit" value="돌아가기">
			</form>
<%
		}
		// 신청 참가일 경우
		else {		
%>		
			<!-- 참가 명단 입력 받아 insert_user_list.jsp로 넘기는 form -->
			<form name="myForm" action="insert_user_list.jsp" method="post" onsubmit="return validateForm()">
				<table border=1 id="TblAttach">
					<tr>
			           	<td colspan="2">신청자 명단</td>
			           	<td colspan="2">   
							<input type="button" value="추가" onclick="addItem();">  
			                <input type="button" value="삭제" onclick="delItem();">  
			           	</td>
					</tr>
			     	</table>
		    	<input name="cid" value="<%= cid %>" type="hidden">
		    	<input name="cloginid" value="<%= cloginid %>" type="hidden">
		    	<input name="cdatestart" value="<%= cdatestart %>" type="hidden">  
		     	<input name="cdateend" value="<%= cdateend %>" type="hidden">       	
		      	<input type="submit" value="명단 등록">
			</form>
<%
		}
		long key1 = 1759, key2 = 29, key3 = 19700101;	// 암호키

		String url = "http://192.168.211.233:8080/JSPDB/attendance.jsp?param=";
		File path = new File(application.getRealPath("/") + "qrcode/images/");
		String savedFileName = ""+cid;
		String codePath = "";	// QR코드 png파일의 경로를 저장할 변수
		
		if(!path.exists()) path.mkdirs();
		QRCodeWriter writer = new QRCodeWriter();
		
		// 기간 중 날짜 목록 생성
		DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		Calendar cal = Calendar.getInstance();
		java.util.Date startDate = df.parse(cdatestart);
		java.util.Date endDate = df.parse(cdateend);
		long diff = (endDate.getTime() - startDate.getTime()) / (24 * 60 * 60 * 1000);	// 시작일부터 종료일까지의 날짜 계산 ex) 2019-11-13 ~ 2019-11-15 = 48시간 = 2일 
		Integer days = (int)(long)diff + 1;	// 시작일과 종료일 모두 포함하는 기간 = diff + 1일
		cal.setTime(startDate);
		
		String[] codePaths = new String [days];
%>
	<select id="id-codes" name="codes" onchange="change()">
<%
		int i=0;
		// QR코드 생성 
		while(true) {
			savedFileName = (cid + df.format(cal.getTime())).toString();	// png 파일명(=날짜와 content_id 조합)
			String temp = df.format(cal.getTime()).toString().replace("-",""); // 2019-11-08 --> 20191108
			long val = ((Long.parseLong(temp) + key3) * key1 + cid) * key2; // 우변의 식을 통해 생성되는 암호값
			
			// QR코드 생성 후 파일로 저장
			BitMatrix qrCode = writer.encode(url + val, BarcodeFormat.QR_CODE, 500, 500);
			BufferedImage qrImage = MatrixToImageWriter.toBufferedImage(qrCode);
			ImageIO.write(qrImage, "PNG", new File(path, savedFileName + ".png"));
			
			// 화면에 QR코드 출력
			codePath = request.getContextPath() + "/qrcode/images/" + savedFileName + ".png";
			codePaths[i] = codePath;
%>
		<option value="<%=codePaths[i] %>"><%=df.format(cal.getTime()) %></option>			
<%
			// 종료일까지 증가하면 반복문 탈출
			if(df.format(cal.getTime()).equals(cdateend)) break;
			i++;
			cal.add(Calendar.DATE, 1); // 날짜 1 증가
		}
%>		
	</select>
	<!-- 화면에 QR코드 출력 부분 -->
	<p id="img_out"><img src="<%=codePaths[0]%>"></p>
<%
	}
	// 에러 발생 경우
	//	- 뒤로가기를 눌러 new_content.jsp로 돌아간 뒤 바로 다시 make_new_content.jsp로 오는 경우(content_id가 같음)
	//	 -> content_list.jsp로 돌아가는 버튼을 표시해 돌아갈 수 있도록 함
	catch(SQLException se) {
		System.out.println("SQL Exception: " + se.getMessage());
		out.println("새로운 일정을 추가하려면 일정 리스트 페이지로 돌아가 일정 추가 버튼을 눌러주세요.");
		/* // 잘못 만들어진 일정을 삭제
		PreparedStatement stmt_del = null, stmt_del_mem = null;
		try {
			String sql_del = "delete from content_list where CONTENT_ID = '"+cid+"'";
			String sql_del_mem = "delete from content_member_list where CONTENT_ID = '"+cid+"'";
			stmt_del = con.prepareStatement(sql_del);
			stmt_del_mem = con.prepareStatement(sql_del);
			stmt_del.executeUpdate();
			stmt_del_mem.executeUpdate();
		}
		finally {
			try {
				if(stmt_del!=null) stmt_del.close();
				if(stmt_del_mem!=null) stmt_del_mem.close();
			}
			catch(SQLException se2) {
				System.out.println("SQL Exception2: " + se2.getMessage());
			}
		} */
%>
		<form action="content_list.jsp" method="post">
			<input name="loginID" value="<%= cloginid %>" type="hidden">
			<input type="submit" value="돌아가기">
		</form>
<%
	}
	finally {
		if(stmt != null) try{stmt.close();} catch(SQLException sqle){}
		if(con != null) try{con.close();} catch(SQLException sqle){}
	}
%>	
</div>
</body>
</html>