FROM nixos/nix:2.28.3

RUN printf '%s\n' \
  'experimental-features = nix-command flakes' \
  'accept-flake-config = true' \
  'sandbox = false' \
  > /etc/nix/nix.conf

WORKDIR /work

CMD ["bash"]
