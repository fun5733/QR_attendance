/*
 * 입력 제한 함수 제공
 */
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