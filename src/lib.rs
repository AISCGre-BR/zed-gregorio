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
        // Try to find gregorio-lsp in PATH (installed globally via npm)
        if let Some(server_path) = worktree.which("gregorio-lsp") {
            self.cached_server_path = Some(server_path.clone());
            return Ok(zed::Command {
                command: server_path,
                args: vec!["--stdio".to_string()],
                env: Default::default(),
            });
        }

        // Try to find it via node + npx
        if let Some(npx_path) = worktree.which("npx") {
            return Ok(zed::Command {
                command: npx_path,
                args: vec!["gregorio-lsp".to_string(), "--stdio".to_string()],
                env: Default::default(),
            });
        }

        // Try to use cached path from previous successful resolution
        if let Some(ref cached) = self.cached_server_path {
            return Ok(zed::Command {
                command: cached.clone(),
                args: vec!["--stdio".to_string()],
                env: Default::default(),
            });
        }

        Err(
            "gregorio-lsp not found. Install it with: npm install -g gregorio-lsp\n\
             Make sure Node.js >= 16 is installed and in your PATH."
                .to_string(),
        )
    }
}

zed::register_extension!(GregorioExtension);
