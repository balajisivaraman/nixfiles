{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.emacs;
  myEmacsPackage = with pkgs;
    ((emacsPackagesFor emacsNativeComp).emacsWithPackages (epkgs: with epkgs; [
      ace-window
      all-the-icons
      all-the-icons-dired
      auctex
      avy
      beginend
      bibtex-completion
      cape
      cargo
      consult
      corfu
      corfu-doc
      change-inner
      citar
      clojure-mode
      clj-refactor
      crux
      ctrlf
      dash
      deadgrep
      deft
      diredfl
      doom-modeline
      easy-kill
      eglot
      embark
      embrace
      exec-path-from-shell
      expand-region
      f
      fish-mode
      flymake-proselint
      focus-autosave-mode
      git-timemachine
      hardhat
      haskell-mode
      hydra
      ignoramus
      kind-icon
      kubernetes
      ledger-mode
      lin
      magit
      magit-delta
      marginalia
      markdown-mode
      modus-themes
      multiple-cursors
      ng2-mode
      nix-mode
      nyan-mode
      orderless
      org
      org-bullets
      org-contrib
      org-modern
      org-noter
      org-roam
      paredit
      pdf-tools
      persistent-scratch
      pinentry
      pulsar
      python
      pyenv-mode
      rainbow-delimiters
      restclient
      restart-emacs
      rg
      rust-mode
      s
      selected
      shift-number
      sudo-edit
      toml-mode
      tree-sitter
      tree-sitter-langs
      typescript-mode
      undo-tree
      use-package
      vertico
      vterm
      wgrep
      which-key
      whitespace-cleanup-mode
      yaml-mode
      yasnippet
      yasnippet-snippets
    ]));
in
{
  options = {
    programs = {
      emacs = {
        enable = mkOption { type = types.bool; default = false; };
      };
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (import (builtins.fetchGit {
        url = "https://github.com/nix-community/emacs-overlay.git";
        ref = "master";
        rev = "29dcfbc1b29ae7281e95367e0f2358b44224a46e"; # change the revision
      }))
    ];
    services.emacs.package = myEmacsPackage;
    services.emacs.enable = true;
    environment.systemPackages = [ myEmacsPackage ];
  };
}
