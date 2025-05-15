import * as pulumi from "@pulumi/pulumi";
import * as tailscale from "@pulumi/tailscale";

const tailscaleProvider = new tailscale.Provider("ts", {
  apiKey: new pulumi.Config("tailscale").requireSecret("apiKey"),
  tailnet: new pulumi.Config("tailscale").require("tailnet"),
});

const policy = {
  "hosts": {
    "oci-home": "100.64.0.10"
  },
  "tagOwners": {
    "tag:oci-aca-001": ["group:admins", "user:you@example.com"],
    "tag:oci-home": ["group:admins"]
  },

  "acls": [
    {
      "action": "accept",
      "src": ["tag:oci-aca-001"],   // 발신지
      "dst": ["oci-home:*"]         // 목적지: 모든 프로토콜·포트
    },

    {
      "action": "deny",
      "src": ["tag:oci-aca-001"],
      "dst": ["*:*"]
    },

    {
      "action": "accept",
      "src": ["*"],
      "dst": ["*:*"]
    }
  ]
}

const acl = new tailscale.Acl(
  "tailnet-acl",                              // Pulumi 리소스 이름
  {
    acl: JSON.stringify(policy),              // JSON 또는 HuJSON 문자열
    overwriteExistingContent: true,          // 안전모드: false 권장
    resetAclOnDestroy: false,                 // 스택 삭제 시 기본 ACL로 롤백 X
  },
  { provider: tailscaleProvider },
);

export const aclId = acl.id;
