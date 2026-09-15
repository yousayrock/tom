#![recursion_limit = "256"]

use anyhow::Result;
use goose_cli::cli::cli;

#[cfg(windows)]
fn enable_windows_vt_processing() {
    let _ = console::Term::stdout().features().colors_supported();
    let _ = console::Term::stderr().features().colors_supported();
}

async fn run() -> Result<()> {
    if let Err(error) = goose_cli::logging::setup_logging(None) {
        eprintln!("Warning: Failed to initialize logging: {error}");
    }

    let result = cli().await;

    #[cfg(feature = "otel")]
    if goose::otel::otlp::is_otlp_initialized() {
        goose::otel::otlp::shutdown_otlp();
    }

    result
}

fn main() -> Result<()> {
    #[cfg(windows)]
    enable_windows_vt_processing();

    let handle = std::thread::Builder::new()
        .name("tom-cli-main".to_string())
        .stack_size(8 * 1024 * 1024)
        .spawn(|| {
            let runtime = tokio::runtime::Builder::new_multi_thread()
                .enable_all()
                .build()
                .expect("Failed to build Tokio runtime");
            runtime.block_on(run())
        })
        .map_err(|error| anyhow::anyhow!("Failed to spawn Tom CLI main thread: {error}"))?;

    handle
        .join()
        .map_err(|_| anyhow::anyhow!("Tom CLI main thread panicked"))?
}
