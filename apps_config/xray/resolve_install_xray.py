# resolve subscription link to xray config

import argparse
import json
from pathlib import Path
from urllib.parse import urlparse, parse_qs, unquote


def resolve_subscription_link(subscription_link: str):
    """
    Parse vless://UUID@host:port?key=value&...#remark
    Return: (uuid, host, port:int, params_dict:str->str, remark:str)
    """
    u = urlparse(subscription_link.strip())

    if u.scheme.lower() != "vless":
        raise ValueError(f"Invalid scheme: {u.scheme!r} (expected 'vless')")

    if not u.username:
        raise ValueError("Missing UUID (username) in vless link")
    uuid = u.username

    if not u.hostname:
        raise ValueError("Missing host in vless link")
    host = u.hostname

    if u.port is None:
        raise ValueError("Missing port in vless link")
    port = int(u.port)

    qs = parse_qs(u.query, keep_blank_values=True)
    params = {k: (v[-1] if isinstance(v, list) and v else "") for k, v in qs.items()}

    remark = unquote(u.fragment) if u.fragment else ""
    return uuid, host, port, params, remark


def rename_params(params: dict) -> dict:
    """
    Rename/normalize common subscription keys to names we want to use.
    Notes:
      - vless reality share links often use:
        fp (fingerprint), sni (serverName), pbk (publicKey)
      - You asked fp -> footprint; we'll keep that as an alias too.
    """
    key_map = {
        "fp": "footprint",  # your requested rename
        "sni": "serverName",
        "pbk": "publicKey",
        # some links use 'sid' or 'shortid'
        "sid": "shortId",
        "shortid": "shortId",
        "spx": "spiderX",
    }
    out = {}
    for k, v in params.items():
        out[key_map.get(k, k)] = v
    return out


def update_template_config(
    template: dict,
    uuid: str,
    host: str,
    port: int,
    params: dict,
):
    """
    Mutate template dict in-place to fill outbound proxy fields.
    """
    # Locate outbound "proxy"
    outbounds = template.get("outbounds", [])
    proxy = None
    for ob in outbounds:
        if ob.get("tag") == "proxy":
            proxy = ob
            break
    if proxy is None:
        raise KeyError("Template does not contain an outbound with tag == 'proxy'")

    # Fill vnext
    vnext0 = proxy.setdefault("settings", {}).setdefault("vnext", [{}])[0]
    vnext0["address"] = host
    vnext0["port"] = port
    user0 = vnext0.setdefault("users", [{}])[0]
    user0["id"] = uuid

    # Fill optional user fields
    if "flow" in params and params["flow"]:
        user0["flow"] = params["flow"]
    # vless encryption is usually 'none' in reality share links; keep template default if missing
    if "encryption" in params and params["encryption"]:
        user0["encryption"] = params["encryption"]

    # Fill streamSettings
    ss = proxy.setdefault("streamSettings", {})
    if "type" in params and params["type"]:
        ss["network"] = params["type"]
    if "security" in params and params["security"]:
        ss["security"] = params["security"]

    # Reality settings
    rs = ss.setdefault("realitySettings", {})

    # sni -> serverName
    if "serverName" in params and params["serverName"]:
        rs["serverName"] = params["serverName"]

    # fp -> footprint (your rename). But template expects 'fingerprint'.
    # So: if footprint exists, write it into rs["fingerprint"].
    if "footprint" in params and params["footprint"]:
        rs["fingerprint"] = params["footprint"]
    # also accept direct 'fingerprint' if present
    if "fingerprint" in params and params["fingerprint"]:
        rs["fingerprint"] = params["fingerprint"]

    # pbk -> publicKey
    if "publicKey" in params and params["publicKey"]:
        rs["publicKey"] = params["publicKey"]

    # Optional reality extras if present
    if "shortId" in params and params["shortId"]:
        rs["shortId"] = params["shortId"]
    if "spiderX" in params and params["spiderX"]:
        rs["spiderX"] = params["spiderX"]

    return template


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("subscription_link", type=str)
    parser.add_argument(
        "--template",
        type=str,
        default="xray_config_template.json",
        help="Path to xray_config_template.json",
    )
    parser.add_argument(
        "--output",
        type=str,
        default="config.json",
        help="Output xray config path",
    )
    args = parser.parse_args()

    uuid, host, port, raw_params, remark = resolve_subscription_link(
        args.subscription_link
    )
    params = rename_params(raw_params)

    template_path = Path(args.template)
    with template_path.open("r", encoding="utf-8") as f:
        tpl = json.load(f)

    updated = update_template_config(tpl, uuid, host, port, params)

    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as f:
        json.dump(updated, f, ensure_ascii=False, indent=2)

    print(f"remark = {remark}")
    print(f"written config to: {out_path}")
    print(f"proxy.address = {host}")
    print(f"proxy.port    = {port}")
    print(f"proxy.uuid    = {uuid}")
    # show normalized params for debugging
    print("normalized params =", params)


if __name__ == "__main__":
    main()
