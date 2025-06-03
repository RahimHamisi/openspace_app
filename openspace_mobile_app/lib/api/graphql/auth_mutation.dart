const String registerMutation = r'''
mutation RegisterUser($input: RegistrationInputObject!) {
  registerUser(input: $input) {
    output {
      message
      success
      user {
        id
        username

      }
    }
    user {
      id
      username
  
    }
  }
}
''';