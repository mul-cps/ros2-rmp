# docker-bake.hcl
group "default" {
  targets = ["base", "overlay_arm64", "overlay_amd64"]
}

target "base" {
  dockerfile = "docker/Dockerfile"
  tags = ["ghcr.io/bjoernellens1/ros2_rmp/rmp:base"]
}

target "overlay_arm64" {
  inherits = ["base"]
  dockerfile = "docker/Dockerfile.arm64"
  platforms = ["linux/arm64"]
}

target "overlay_amd64" {
  inherits = ["base"]
  dockerfile = "docker/Dockerfile.amd64"
  platforms = ["linux/amd64"]
}

target "db" {
  dockerfile = "Dockerfile.db"
  tags = ["docker.io/username/db"]
}