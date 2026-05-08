abstract class AuthForm {
  const AuthForm();
}

class InitialAuthFormStatus extends AuthForm {
  const InitialAuthFormStatus();
}

class AuthFormSubmitting extends AuthForm {}

class AuthFormSubmissionSuccess extends AuthForm {}

class AuthFormSubmissionFailed extends AuthForm {
  AuthFormSubmissionFailed(this.exception);

  final Exception exception;
}
