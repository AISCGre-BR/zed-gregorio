use zed_extension_api as zed;

struct GregorioExtension {
    cached_server_path: Option<String>,
}

impl zed::Extension for GregorioExtension {
    fn new() -> Self {
        Self {
            cached_server_path: None,
        }
    }

    fn language_server_command(
        &mut self,
        _language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> zed::Result<zed::Command> {
        // Prefer a pre-installed binary (cargo install gregorio-lsp or system package).
        if let Some(server_path) = worktree.which("gregorio-lsp") {
            self.cached_server_path = Some(server_path.clone());
            return Ok(zed::Command {
                command: server_path,
                args: vec!["--stdio".to_string()],
                env: Default::default(),
            });
        }

        // Use cached path from a previous successful resolution.
        if let Some(ref cached) = self.cached_server_path {
            return Ok(zed::Command {
                command: cached.clone(),
                args: vec!["--stdio".to_string()],
                env: Default::default(),
            });
        }

        Err(
            "gregorio-lsp not found. Install it with:\n\
             \n\
             cargo install --git https://github.com/aiscgre-br/gregorio-lsp \\\n\
               --tag v1.0.0-alpha.1 --bin gregorio-lsp\n\
             \n\
             Make sure ~/.cargo/bin is in your PATH."
                .to_string(),
        )
    }
}

zed::register_extension!(GregorioExtension);
