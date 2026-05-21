// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
	initializePasswordValidation();
	initializePhoneInput();
	initializeBirthdateInput();
	initializeTermsCheckboxes();
	displayUserRole();
});

// Display user role
function displayUserRole() {
	const roleIndicator = document.getElementById('roleIndicator');
	if (roleIndicator) {
		const userRole = sessionStorage.getItem('userRole');
		const roleBadge = roleIndicator.querySelector('.role-badge');
		if (roleBadge && userRole) {
			roleBadge.textContent = userRole === 'patient' ? '환자' : '보호자';
		}
	}
}

// Birthdate format
function initializeBirthdateInput() {
    const birthDateInput = document.getElementById('birthDate');
    
    if (birthDateInput) {
        // min, max 설정 (JavaScript로도)
        const today = new Date();
        const maxDate = today.toISOString().split('T')[0]; // YYYY-MM-DD
        
        birthDateInput.setAttribute('min', '1900-01-01');
        birthDateInput.setAttribute('max', maxDate);
        
        // 입력 시 검증
        birthDateInput.addEventListener('change', function(e) {
            const value = e.target.value;
            
            if (!value) return;
            
            const inputDate = new Date(value);
            const year = inputDate.getFullYear();
            const currentYear = new Date().getFullYear();
            
            if (year < 1900) {
                alert('연도는 1900년 이후로 입력해주세요.');
                e.target.value = '';
                return;
            }
            
            if (year > currentYear) {
                alert('미래 날짜는 입력할 수 없습니다.');
                e.target.value = '';
                return;
            }
        });
    }
}
// Password validation - immediate check
function initializePasswordValidation() {
	const passwordInput = document.getElementById('joinPassword');
	const passwordConfirmInput = document.getElementById('joinPasswordConfirm');
	const passwordHint = passwordInput?.parentElement.parentElement.querySelector('.form-hint');

	if (passwordInput && passwordConfirmInput) {
		const passwordRegex = /^(?=.*[a-zA-Z])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{6,16}$/;

		// Password Form
		passwordInput.addEventListener('input', function() {
			if (this.value.length > 0) {
				if (passwordRegex.test(this.value)) {
					passwordHint.textContent = '사용 가능한 비밀번호입니다.';
					passwordHint.className = 'form-hint success';
				} else {
					passwordHint.textContent = '6~16자 영문, 특수문자를 사용해주세요.';
					passwordHint.className = 'form-hint highlight';
				}
			} else {
				passwordHint.textContent = '6~16자 영문, 특수문자를 사용해주세요.';
				passwordHint.className = 'form-hint';
			}

			validatePasswordConfirm();
		});

		// Password = reInput Password
		const validatePasswordConfirm = function() {
			let confirmHint = passwordConfirmInput.parentElement.parentElement.querySelector('.form-hint');

			if (passwordConfirmInput.value.length > 0) {
				if (passwordInput.value === passwordConfirmInput.value) {
					if (!confirmHint) {
						confirmHint = document.createElement('p');
						passwordConfirmInput.parentElement.parentElement.appendChild(confirmHint);
					}
					confirmHint.textContent = '비밀번호가 일치합니다.';
					confirmHint.className = 'form-hint success';
					passwordConfirmInput.setCustomValidity('');
				} else {
					if (!confirmHint) {
						confirmHint = document.createElement('p');
						passwordConfirmInput.parentElement.parentElement.appendChild(confirmHint);
					}
					confirmHint.textContent = '일치하지 않습니다.';
					confirmHint.className = 'form-hint error';
					passwordConfirmInput.setCustomValidity('비밀번호가 일치하지 않습니다.');
				}
			} else {
				if (confirmHint) {
					confirmHint.remove();
				}
				passwordConfirmInput.setCustomValidity('');
			}
		};

		passwordConfirmInput.addEventListener('input', validatePasswordConfirm);
		passwordConfirmInput.addEventListener('change', validatePasswordConfirm);
	}
}

// Phone number formatting
function initializePhoneInput() {
	const phoneInput = document.getElementById('phone');
	if (phoneInput) {
		phoneInput.addEventListener('input', function(e) {
			let value = e.target.value.replace(/[^\d]/g, ''); // Remove non-digits

			if (value.length > 11) {
				value = value.slice(0, 11);
			}

			// Format: 010-1234-5678 or 011-123-4567
			let formatted = '';
			if (value.length <= 3) {
				formatted = value;
			} else if (value.length <= 6) {
				formatted = value.slice(0, 3) + '-' + value.slice(3);
			} else if (value.length <= 10) {
				// For 010-123-4567 format (10 digits)
				formatted = value.slice(0, 3) + '-' + value.slice(3, 6) + '-' + value.slice(6);
			} else {
				// For 010-1234-5678 format (11 digits)
				formatted = value.slice(0, 3) + '-' + value.slice(3, 7) + '-' + value.slice(7);
			}

			e.target.value = formatted;
		});

		// Validation on blur
		phoneInput.addEventListener('blur', function(e) {
			const value = e.target.value.replace(/[^\d]/g, '');
			const prefix = value.slice(0, 3);

			// Check if starts with 010 or 011
			if (prefix !== '010' && prefix !== '011') {
				alert('전화번호는 010 또는 011로 시작해야 합니다.');
				e.target.value = '';
				return;
			}

			// Check length: 010-XXXX-XXXX (11) or 011-XXX-XXXX (10)
			if (prefix === '010' && value.length !== 11) {
				alert('010 전화번호는 11자리여야 합니다. (예: 010-1234-5678)');
				e.target.value = '';
			} else if (prefix === '011' && value.length !== 10) {
				alert('011 전화번호는 10자리여야 합니다. (예: 011-123-4567)');
				e.target.value = '';
			}
		});
	}
}

// Toggle password visibility
function togglePassword(inputId) {
	const input = document.getElementById(inputId);
	const button = input.nextElementSibling;

	if (input.type === 'password') {
		input.type = 'text';
		button.innerHTML = '<svg class="eye-icon" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>';
	} else {
		input.type = 'password';
		button.innerHTML = '<svg class="eye-icon" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>';
	}
}

// Select gender
function selectGender(button, value) {
	const buttons = button.querySelectorAll('.gender-btn');
	buttons.forEach(btn => btn.classList.remove('active'));
	button.classList.add('active');
	document.getElementById('gender').value = value;
}

// Handle email domain change
function handleEmailDomainChange() {
	const select = document.getElementById('emailDomain');
	const customInput = document.getElementById('emailDomainCustom');

	if (select.value === 'custom') {
		customInput.style.display = 'block';
		select.style.display = 'none';
		customInput.focus();
	} else {
		customInput.style.display = 'none';
		select.style.display = 'block';
	}
}

// Toggle all terms
function toggleAllTerms() {
	const agreeAll = document.getElementById('agreeAll');
	const checkboxes = document.querySelectorAll('.term-checkbox');

	checkboxes.forEach(checkbox => {
		checkbox.checked = agreeAll.checked;
	});
}

// Initialize terms checkboxes
function initializeTermsCheckboxes() {
	const checkboxes = document.querySelectorAll('.term-checkbox');
	const agreeAll = document.getElementById('agreeAll');

	if (checkboxes.length && agreeAll) {
		checkboxes.forEach(checkbox => {
			checkbox.addEventListener('change', function() {
				const allChecked = Array.from(checkboxes).every(cb => cb.checked);
				agreeAll.checked = allChecked;
			});
		});
	}
}

// Toggle term detail
function toggleTermDetail() {
	// Placeholder for expanding terms detail
	alert('약관 상세 내용을 표시합니다.');
}

// Handle join form submission
function handleJoin(event) {
	event.preventDefault();

	const joinId = document.getElementById('joinId').value;
	const joinPassword = document.getElementById('joinPassword').value;
	const joinPasswordConfirm = document.getElementById('joinPasswordConfirm').value;
	const userName = document.getElementById('userName').value;
	const birthDate = document.getElementById('birthDate');
	const gender = document.getElementById('gender').value;
	const phone = document.getElementById('phone').value;
	const emailId = document.getElementById('emailId').value;
	const emailDomain = document.getElementById('emailDomain').value;
	const emailDomainCustom = document.getElementById('emailDomainCustom').value;

	//UserRole은 joinStep0.jsp여서 동적 입력
	const userRole = sessionStorage.getItem('userRole');
	const hiddenInput = document.createElement('input');
	hiddenInput.type = 'hidden';
	hiddenInput.name = 'userRole';
	hiddenInput.value = userRole;
	event.target.appendChild(hiddenInput);

	// 생년월일 검증
	if (birthDate) {
		const date = new Date(birthDate);
		const year = date.getFullYear();
		const currentYear = new Date().getFullYear();

		if (year < 1900 || year > currentYear) {
			alert('연도는 1900년부터 ${currentYear}년 사이로 입력해주세요.');
			return;
		}
	}

	// 성별 검증
	if (!gender) {
	    alert('성별을 선택해주세요.');
	    return;
	}
	
	// 필수 검증(아이디, 비밀번호, 이름, 전화번호)
	if (!joinId || !joinPassword || !joinPasswordConfirm || !userName || !phone) {
		alert('필수 항목을 모두 입력해주세요.');
		return;
	}

	// ID 검증
	const idRegex = /^[a-zA-Z0-9]{4,20}$/;
	if (!idRegex.test(joinId)) {
		alert('아이디는 4~20자의 영문과 숫자만 사용할 수 있습니다.');
		return;
	}

	// 비밀번호 검증
	const passwordRegex = /^(?=.*[a-zA-Z])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{6,16}$/;
	if (!passwordRegex.test(joinPassword)) {
		alert('비밀번호는 6~16자의 영문과 특수문자를 포함해야 합니다.');
		return;
	}

	// 비밀번호 일치 확인
	if (joinPassword !== joinPasswordConfirm) {
		alert('비밀번호가 일치하지 않습니다.');
		return;
	}

	// 전화번호 검증
	const phoneDigits = phone.replace(/[^\d]/g, '');
	const phonePrefix = phoneDigits.slice(0, 3);

	if (phonePrefix !== '010' && phonePrefix !== '011') {
		alert('전화번호는 010 또는 011로 시작해야 합니다.');
		return;
	}

	if ((phonePrefix === '010' && phoneDigits.length !== 11) ||
		(phonePrefix === '011' && phoneDigits.length !== 10)) {
		alert('올바른 전화번호 형식이 아닙니다.');
		return;
	}

	// 약관 동의 확인
	const requiredTerms = document.querySelectorAll('.term-checkbox[data-required="true"]');
	const allRequiredChecked = Array.from(requiredTerms).every(checkbox => checkbox.checked);

	if (!allRequiredChecked) {
		alert('필수 약관에 동의해주세요.');
		return;
	}

	// 이메일 검증 (선택사항)
	if (emailId) {
		const domain = emailDomain === 'custom' ? emailDomainCustom : emailDomain;
		if (!domain) {
			alert('이메일 도메인을 선택하거나 입력해주세요.');
			return;
		}
	}

	console.log('검증 통과! 서버로 제출합니다.');
	event.target.submit();
}

// Go back
function goBack() {
	window.location.href = 'joinStep0.jsp';
}

// Login Form Validation
function validateLogin() {
	const loginId = document.getElementById('loginId').value;
	const loginPassword = document.getElementById('loginPassword').value;

	if (!loginId || !loginPassword) {
		alert('아이디와 비밀번호를 입력해주세요.');
		return false;
	}
	return true; // Form 제출 허용
}