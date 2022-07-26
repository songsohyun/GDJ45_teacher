package com.goodee.ex15.interceptor;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.util.WebUtils;

import com.goodee.ex15.domain.MemberDTO;
import com.goodee.ex15.service.MemberService;

public class KeepLoginInterceptor implements HandlerInterceptor {

	@Autowired
	private MemberService memberService;
	
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
			throws Exception {
	
		// 쿠키로 저장된 keepLogin 정보를 확인해서
		// 해당 정보를 가진 사용자 정보를 DB에서 가져온 뒤 session에 loginMember 이름으로 올림
		
		Cookie cookie = WebUtils.getCookie(request, "keepLogin");
		
		if(cookie != null) {
			
			MemberDTO loginMember = memberService.getMemberBySessionId(cookie.getValue());
			if (loginMember != null) {
				request.getSession().setAttribute("loginMember", loginMember);
			}
			
		}
		
		return true;
		
	}
	
}
