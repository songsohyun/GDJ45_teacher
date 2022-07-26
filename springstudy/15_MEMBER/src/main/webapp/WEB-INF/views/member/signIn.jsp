<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style>
	.ok {
		color: limegreen;
	}
	.dont {
		color: crimson;
	}
</style>
<script src="../resources/js/jquery-3.6.0.js"></script>
<script>

	/* 페이지 로드 이벤트 */
	$(function(){
		fnIdCheck();
		fnPwCheck();
		fnPwConfirm();
		fnEmailAuth();
		fnToUpperCase();
		fnSignIn();
	})
	
	/* 함수 */
	
	// 8. 회원가입
	function fnSignIn(){
		$('#f').on('submit', function(event){
			if(idPass == false){
				alert('아이디를 확인하세요.');
				event.preventDefault();
				return false;
			}
			else if(pwPass == false || rePwPass == false){
				alert('비밀번호를 확인하세요.');
				event.preventDefault();
				return false;
			}
			else if(authCodePass == false){
				alert('이메일 인증을 받아야 합니다.');
				event.preventDefault();
				return false;
			}
			return true;
		})
	}
	
	// 7. 입력을 무조건 대문자로 처리
	function fnToUpperCase(){
		$('#authCode').on('keyup', function(){
			$('#authCode').val($('#authCode').val().toUpperCase());
		})
	}
	
	// 6. 인증코드 검증
	let authCodePass = false;
	function fnVerifyAuthCode(authCode){  // 이메일로 전송한 인증코드
		$('#btnVerifyAuthCode').on('click', function(){
			if($('#authCode').val() == authCode){
				alert('인증되었습니다.');
				authCodePass = true;
			} else {
				alert('인증에 실패했습니다.');
				authCodePass = false;
			}
		})
	}
	
	/*
	function fnEmailCheck(){
		return new Promise(function(resolve, reject){
			이메일 형식이 틀리면     reject(1000);
			$.ajax({
				이메일 중복이 없으면 resolve();
				이메일 중복이 있으면 reject(2000); 
			})
		});
	}
	
	function fnEmailAuth(){
		fnEmailCheck().then(
			function(){
				$.ajax({
					인증코드 전송하는 ajax 처리
				})
			}
		).catch(
			function(code){
				code에 따른 alert 처리
			}
		)
	}
	*/
	
	// 5. 이메일 중복체크
	//    1) 이메일 중복을 체크하는 ajax를 동작시킨다.
	//    2) ajax의 처리 결과에 따라서 이후 동작이 달라진다.
	//       (1) 중복이 없는 경우 : fnAuthCodeSuccess => 이메일 인증 진행(이메일을 보내는 Service를 동작시킬 ajax 처리가 필요함.)
	//       (2) 중복이 있는 경우 : fnAuthCodeFail    => 오류 처리
	
	// ※ ajax 처리 결과를 이용해서 또 다른 ajax 처리가 필요한 상황
	//   Promise 처리를 해야 한다.
	
	function fnEmailCheck(){
		return new Promise(function(resolve, reject) {
			// 1) 이메일 정규식 체크
			let regEmail = /^[a-zA-Z0-9-_]+@[a-zA-Z0-9]+(\.[a-zA-Z]{2,}){1,2}$/;  // 실제 서비스에서 그대로 사용 가능.
			if(regEmail.test($('#email').val())==false){
				reject(1000);      // reject는 Promise 객체의 catch 메소드에 전달되는 함수
				                   // 이메일 형식이 잘못된 경우의 코드값 : 1000
				return;
			}
			// 2) 이메일 중복 체크
			$.ajax({
				url: '${contextPath}/member/emailCheck',
				type: 'get',
				data: 'email=' + $('#email').val(),
				dataType: 'json',
				success: function(obj){
					if(obj.res == null){
						resolve();     // resolve는 Promise 객체의 then 메소드에 전달되는 함수
					} else {
						reject(2000);  // reject는 Promise 객체의 catch 메소드에 전달되는 함수
						               // 중복된 이메일이 있는 경우의 코드값 : 2000
					}
				}
			})
		});
	}
	
	// 4. 이메일 인증
	function fnEmailAuth(){
		$('#btnGetAuthCode').on('click', function(){
			fnEmailCheck().then(
				function(){
					$.ajax({
						url: '${contextPath}/member/sendAuthCode',
						type: 'get',
						data: 'email=' + $('#email').val(),
						dataType: 'json',
						success: function(obj){  // obj에는 발송한 인증코드(authCode)가 저장되어 있음.
							alert('인증코드를 발송했습니다. 이메일을 확인하세요.');
							fnVerifyAuthCode(obj.authCode);  // 발송한 인증코드와 사용자가 입력한 인증코드가 일치하는지 점검.
						},
						error: function(jqXHR){
							alert('인증코드 발송이 실패했습니다.');
						}
					})
				}
			).catch(
				function(code){
					if(code == 1000){
						$('#emailMsg').text('이메일 형식이 올바르지 않습니다.').addClass('dont').removeClass('ok');
						$('#authCode').prop('readonly', true);
					} else if(code == 2000){
						$('#emailMsg').text('이미 사용 중인 이메일입니다.').addClass('dont').removeClass('ok');
						$('#authCode').prop('readonly', true);
					}
				}
			)
		})
	}
	
	// 3. 비밀번호 입력확인
	let rePwPass = false;
	function fnPwConfirm(){
		$('#pwConfirm').on('keyup', function(){
			if($('#pwConfirm').val() != '' && $('#pw').val() != $('#pwConfirm').val()){
				$('#pwConfirmMsg').text('비밀번호를 확인하세요.').addClass('dont').removeClass('ok');
				rePwPass = false;
			} else {
				$('#pwConfirmMsg').text('');
				rePwPass = true;
			}
		})
	}
	
	// 2. 비밀번호 정규식
	let pwPass = false;
	function fnPwCheck(){
		// 비밀번호 정규식 검사
		$('#pw').on('keyup', function(){
			let regPw = /^[0-9]{1,4}$/;  // 숫자 1~4자
			if(regPw.test($('#pw').val())==false){
				$('#pwMsg').text('8~16자 영문 대 소문자, 숫자, 특수문자를 사용하세요.').addClass('dont').removeClass('ok');
				pwPass = false;
			} else {
				$('#pwMsg').text('사용 가능한 비밀번호입니다.').addClass('ok').removeClass('dont');
				pwPass = true;
			}
		})
	}

	// 1. 아이디 정규식 & 중복체크
	let idPass = false;
	function fnIdCheck(){
		$('#id').on('keyup', function(){
			// 정규식 체크하기
			let regId = /^[a-z]{1,32}$/;  // 소문자 1~32자 사이(실제 서비스는 바꿔야 함)
			if(regId.test($('#id').val())==false){
				$('#idMsg').text('아이디는 어쩌구 저쩌구 입니다.').addClass('dont').removeClass('ok');
				idPass = false;
				return;
			}
			// 아이디 중복 체크
			$.ajax({
				url: '${contextPath}/member/idCheck',
				type: 'get',
				data: 'id=' + $('#id').val(),
				dataType: 'json',
				success: function(obj){
					if(obj.res == null){
						$('#idMsg').text('멋진 아이디네요!').addClass('ok').removeClass('dont');
						idPass = true;
					} else {
						$('#idMsg').text('이미 사용중이거나 탈퇴한 아이디입니다.').addClass('dont').removeClass('ok');
						idPass = false;
					}
				},
				error: function(jqXHR){
					$('#idMsg').text(jqXHR.responseText).addClass('dont').removeClass('ok');
					idPass = false;
				}
			})
		})
	}
	
</script>
</head>
<body>
	
	<h3>회원 가입</h3>
	
	<form id="f" action="${contextPath}/member/signIn" method="post">
	
		<input type="hidden" name="location" value="${agreements[0]}">
		<input type="hidden" name="promotion" value="${agreements[1]}">
		
		<label for="id">
			아이디<br>
			<input type="text" name="id" id="id"><br>
			<span id="idMsg"></span>
		</label><br><br>
		
		<label for="pw">
			비밀번호<br>
			<input type="password" name="pw" id="pw"><br>
			<span id="pwMsg"></span>
		</label><br><br>
		
		<label for="pwConfirm">
			비밀번호 재확인<br>
			<input type="password" id="pwConfirm"><br>
			<span id="pwConfirmMsg"></span>
		</label><br><br>
		
		<label for="name">
			이름<br>
			<input type="text" name="name" id="name"><br>
		</label><br><br>
		
		<label for="email">
			이메일<br>
			<input type="text" name="email" id="email">
			<input type="button" value="인증번호받기" id="btnGetAuthCode"><br>
			<span id="emailMsg"></span><br>
			<input type="text" name="authCode" id="authCode" placeholder="인증코드 입력">
			<input type="button" value="인증하기" id="btnVerifyAuthCode"><br><br>
		</label><br><br>
		
		<button>가입하기</button>
		<input type="button" value="취소하기" onclick="location.href='${contextPath}'">
	
	</form>
	
</body>
</html>