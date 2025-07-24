// 用户名验证（支持中文、英文、数字、下划线）
function isValidUsername(username) {
  const usernameRegex = /^[a-zA-Z0-9_\u4e00-\u9fa5]{3,50}$/;
  return usernameRegex.test(username);
}

// 邮箱格式验证
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

// 手机号格式验证（中国手机号）
function isValidPhone(phone) {
  const phoneRegex = /^1[3-9]\d{9}$/;
  return phoneRegex.test(phone);
}

// 密码强度验证
function isStrongPassword(password) {
  return password && password.length >= 6 && password.length <= 100;
}

// 注册输入验证
function validateRegisterInput({ username, password, confirmPassword, email, phone }) {
  const errors = [];

  // 用户名验证
  if (!username || username.trim().length === 0) {
    errors.push('用户名不能为空');
  } else if (!isValidUsername(username.trim())) {
    errors.push('用户名只能包含中文、英文、数字、下划线，长度3-50个字符');
  }

  // 密码验证
  if (!password) {
    errors.push('密码不能为空');
  } else if (!isStrongPassword(password)) {
    errors.push('密码长度需要在6-100个字符之间');
  }

  // 确认密码验证
  if (!confirmPassword) {
    errors.push('请确认密码');
  } else if (password !== confirmPassword) {
    errors.push('两次输入的密码不一致');
  }

  // 邮箱验证（可选）
  if (email && email.trim() && !isValidEmail(email.trim())) {
    errors.push('邮箱格式不正确');
  }

  // 手机号验证（可选）
  if (phone && phone.trim() && !isValidPhone(phone.trim())) {
    errors.push('手机号格式不正确');
  }

  return {
    isValid: errors.length === 0,
    errors
  };
}

// 登录输入验证
function validateLoginInput({ username, password }) {
  const errors = [];

  if (!username || username.trim().length === 0) {
    errors.push('用户名不能为空');
  }

  if (!password || password.length === 0) {
    errors.push('密码不能为空');
  }

  return {
    isValid: errors.length === 0,
    errors
  };
}

module.exports = {
  validateRegisterInput,
  validateLoginInput,
  isValidEmail,
  isValidPhone,
  isValidUsername,
  isStrongPassword
};