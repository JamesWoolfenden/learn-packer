build {
sources=[
  "source.docker.base1604"
  ]
post-processor "docker-tag" {
  repository="james"
      tag= ["0.1"]
}

}
