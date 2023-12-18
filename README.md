# ros2_rmp

For the build with docker buildx bake you will need binfmt dependencies for arm64 architecture, as we are doing a multiplatform build (Works on PCs as well as Jetson Nano, Raspberry Pi, Apple Silicon Devices).

For Robot:
```
docker buildx bake overlay --load
docker buildx bake overlay --push
```
e.g.:
```
docker compose up -d controller
```
For PC:
```
docker buildx bake guis --load
docker buildx bake guis --push
```
--> get into container shell:
```
docker compose run guis
```
or
```
docker compose up rviz2
```
