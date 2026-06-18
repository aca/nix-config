# Container Machine 포트 포워딩

container machine 안에서 띄운 로컬 서버를 Mac에서도 같은 localhost 포트로 접근하기 위한 구성이다.

예:

```bash
# container machine 안에서 서버 실행
python -m http.server 8080

# Mac에서 접근
open http://localhost:8080
```

## 구조

Mac은 `192.168.64.1`, container machine은 `192.168.64.100`을 사용한다.

Mac 쪽에서는 `txxx.configuration.nix`의 `container-machine-sshd` launchd daemon이 `/usr/sbin/sshd`를 `2222` 포트로 띄운다.

```text
container machine                Mac
127.0.0.1:8080  <--- ssh -R ---  127.0.0.1:8080
192.168.64.100                  192.168.64.1:2222
```

container machine에서 Mac으로 SSH 접속이 가능하므로, container 쪽에서 reverse tunnel을 만든다.

```bash
ssh -R 127.0.0.1:8080:127.0.0.1:8080 kyungrok.chung@192.168.64.1 -p 2222
```

이후 Mac에서 `localhost:8080`으로 접속하면 SSH 터널을 통해 container machine의 `localhost:8080`으로 전달된다.

## 수동 포워딩

container machine 안에서:

```bash
mac-forward 8080
```

여러 포트도 한 번에 가능하다.

```bash
mac-forward 3000 5173 8080
```

기본 접속 대상은 다음과 같다.

```text
kyungrok.chung@192.168.64.1 -p 2222
```

필요하면 환경 변수로 바꿀 수 있다.

```bash
MAC_FORWARD_SSH_HOST=mac MAC_FORWARD_SSH_PORT=2222 mac-forward 8080
```

## 자동 포워딩

container machine 안에서:

```bash
mac-forward-auto
```

`ss -ltn`으로 container 안의 listening TCP 포트를 주기적으로 확인하고, 발견한 포트마다 reverse tunnel을 만든다. 서버가 종료되어 포트가 사라지면 해당 tunnel도 종료한다.

특정 포트만 감시하려면 인자로 지정한다.

```bash
mac-forward-auto 8080 5173
```

기본 자동 감시에서는 `1024` 미만 포트와 `22`, `2222`, `1080`을 제외한다. 필요하면 환경 변수로 조정한다.

```bash
MAC_FORWARD_MIN_PORT=1 MAC_FORWARD_EXCLUDE_PORTS="22 2222" mac-forward-auto
```

## 접근 범위

Mac의 `sshd`는 `GatewayPorts=no`로 실행된다. 따라서 reverse tunnel로 열린 포트는 Mac의 `127.0.0.1:<port>`에만 bind되고, 같은 네트워크의 다른 장비에는 노출되지 않는다.

외부 장비에서도 접근 가능하게 하려면 `GatewayPorts` 설정과 `-R` bind address를 별도로 바꿔야 한다. 기본 구성은 로컬 개발용이다.

