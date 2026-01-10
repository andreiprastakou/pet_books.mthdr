class AuthorRef {
  static parse(data) {
    return {
      id: data['id'],
      fullname: data['fullname'],
    }
  }
}

export default AuthorRef
