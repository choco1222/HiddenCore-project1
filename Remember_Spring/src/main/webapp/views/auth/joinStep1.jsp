<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="container">
        <div class="survey-wrapper">
            <!-- 역할 표시 -->
            <div class="role-indicator" id="roleIndicator">
                <span class="role-badge">환자</span>
            </div>

            <div class="question-area">
                <h1 class="question-title">회원가입</h1>
                <p class="question-description">정확한 정보를 입력해주세요</p>
            </div>

            <form class="auth-form" id="joinForm" onsubmit="handleJoin(event)">
                <div class="answer-area">
                    <!-- 아이디 입력 -->
                    <div class="form-group">
                        <label for="joinId" class="form-label">아이디</label>
                        <input type="text" id="joinId" name="joinId" class="form-input" 
                               pattern="[a-zA-Z0-9]{4,20}" 
                               title="4~20자의 영문 또는 숫자를 사용해주세요"
                               required>
                    </div>

                    <!-- 비밀번호 입력 -->
                    <div class="form-group">
                        <label for="joinPassword" class="form-label">비밀번호</label>
                        <div class="password-wrapper">
                            <input type="password" id="joinPassword" name="joinPassword" class="form-input" 
                                   pattern="(?=.*[a-zA-Z])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{6,16}"
                                   title="6~16자의 영문과 특수문자를 포함해야 합니다"
                                   required>
                            <button type="button" class="password-toggle" onclick="togglePassword('joinPassword')">
                                <svg class="eye-icon" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                    <circle cx="12" cy="12" r="3"></circle>
                                </svg>
                            </button>
                        </div>
                        <p class="form-hint">6~16자 영문, 특수문자를 사용해주세요.</p>
                    </div>

                    <!-- 비밀번호 확인 -->
                    <div class="form-group">
                        <label for="joinPasswordConfirm" class="form-label">비밀번호 확인</label>
                        <div class="password-wrapper">
                            <input type="password" id="joinPasswordConfirm" name="joinPasswordConfirm" class="form-input" required>
                            <button type="button" class="password-toggle" onclick="togglePassword('joinPasswordConfirm')">
                                <svg class="eye-icon" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                    <circle cx="12" cy="12" r="3"></circle>
                                </svg>
                            </button>
                        </div>
                    </div>

                    <!-- 이름 입력 -->
                    <div class="form-group">
                        <label for="userName" class="form-label">이름</label>
                        <input type="text" id="userName" name="userName" class="form-input" required>
                    </div>

                    <!-- 생년월일 입력 -->
                    <div class="form-group">
                        <label for="birthDate" class="form-label">생년월일</label>
                        <input type="date" id="birthDate" name="birthDate" class="form-input" required>
                    </div>

                    <!-- 성별 선택 -->
                    <div class="form-group">
                        <label class="form-label">성별</label>
                        <div class="gender-selection">
                            <button type="button" class="gender-btn active" data-value="male" onclick="selectGender(this, 'male')">남자</button>
                            <button type="button" class="gender-btn" data-value="female" onclick="selectGender(this, 'female')">여자</button>
                            <button type="button" class="gender-btn" data-value="other" onclick="selectGender(this, 'other')">선택안함</button>
                        </div>
                        <input type="hidden" id="gender" name="gender" value="male">
                    </div>

                    <!-- 전화번호 -->
                    <div class="form-group">
                        <label for="phone" class="form-label">전화번호</label>
                        <input type="tel" id="phone" name="phone" class="form-input" 
                               placeholder="010-1234-5678"
                               maxlength="13"
                               required>
                    </div>

                    <!-- 이메일 (선택) -->
                    <div class="form-group">
                        <label for="emailId" class="form-label">이메일 <span class="optional-label">(선택)</span></label>
                        <div class="email-input-group">
                            <input type="text" id="emailId" name="emailId" class="form-input email-id" placeholder="이메일">
                            <span class="email-at">@</span>
                            <select id="emailDomain" name="emailDomain" class="form-select email-domain" onchange="handleEmailDomainChange()">
                                <option value="">선택</option>
                                <option value="naver.com">naver.com</option>
                                <option value="gmail.com">gmail.com</option>
                                <option value="daum.net">daum.net</option>
                                <option value="kakao.com">kakao.com</option>
                                <option value="custom">직접 입력</option>
                            </select>
                            <input type="text" id="emailDomainCustom" name="emailDomainCustom" class="form-input email-domain" 
                                   placeholder="직접 입력" style="display: none;">
                        </div>
                    </div>

                    <!-- 약관 동의 -->
                    <div class="form-group" style="margin-top: 2rem;">
                        <div class="terms-container">
                            <!-- 전체 동의 -->
                            <label class="term-item term-all">
                                <input type="checkbox" id="agreeAll" onchange="toggleAllTerms()">
                                <span class="term-text">전체 동의하기</span>
                            </label>

                            <div class="terms-divider"></div>

                            <p class="terms-description">
                                실명 인증된 아이디로 가입, 위치기반서비스 이용약관(선택), 이벤트·혜택 정보 수신(선택) 동의를 포함합니다.
                            </p>

                            <!-- 필수 약관 -->
                            <label class="term-item">
                                <input type="checkbox" name="terms" class="term-checkbox" data-required="true" required>
                                <span class="term-text">
                                    <span class="term-required">필수</span> 이용 약관
                                </span>
                                <a href="#" class="term-link" onclick="event.preventDefault();">보기</a>
                            </label>

                            <label class="term-item">
                                <input type="checkbox" name="terms" class="term-checkbox">
                                <span class="term-text">
                                    <span class="term-required">선택</span> 실명 인증된 아이디로 가입
                                </span>
                            </label>

                            <label class="term-item">
                                <input type="checkbox" name="terms" class="term-checkbox">
                                <span class="term-text">
                                    <span class="term-required">선택</span> 위치기반서비스 이용약관
                                </span>
                                <a href="#" class="term-link" onclick="event.preventDefault();">보기</a>
                            </label>

                            <label class="term-item">
                                <input type="checkbox" name="terms" class="term-checkbox">
                                <span class="term-text">
                                    <span class="term-required">선택</span> 개인정보 수집 및 이용
                                </span>
                                <a href="#" class="term-link" onclick="event.preventDefault();">보기</a>
                            </label>

                            <!-- 개인정보 수집 상세 -->
                            <div class="term-detail">
                                <p class="term-detail-text">	이벤트 · 혜택 정보 수신</p>
                            </div>

                            <!-- 개인정보 수집 안내 펼치기 -->
                            <button type="button" class="term-expand" onclick="toggleTermDetail()">
                                <span>개인정보 수집 및 이용 안내</span>
                                <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                                    <path d="M8 11L3 6h10l-5 5z"/>
                                </svg>
                            </button>

                            <div class="term-footer">
                                <a href="#" class="term-footer-link" onclick="event.preventDefault();">어린이용 안내</a>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="button-container">
                    <button type="button" class="btn btn-secondary" onclick="goBack()">이전</button>
                    <button type="submit" class="btn btn-primary">다음</button>
                </div>
            </form>
        </div>
    </div>

    <script src="./js/auth-script.js"></script>
</body>
</html>
