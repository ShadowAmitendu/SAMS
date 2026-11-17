import { useEffect, useState } from "react";
import {
	Alert,
	Box,
	Button,
	Card,
	CardContent,
	Chip,
	CircularProgress,
	Container,
	Stack,
	Typography,
} from "@mui/material";

const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || "/api/v1").replace(
	/\/$/,
	"",
);

function App() {
	const [health, setHealth] = useState(null);
	const [status, setStatus] = useState("loading");
	const [error, setError] = useState("");
	const [refreshKey, setRefreshKey] = useState(0);

	useEffect(() => {
		const controller = new AbortController();

		async function checkHealth() {
			setStatus("loading");
			setError("");

			try {
				const response = await fetch(`${API_BASE_URL}/health`, {
					signal: controller.signal,
				});

				if (!response.ok) {
					throw new Error(`Backend returned HTTP ${response.status}`);
				}

				setHealth(await response.json());
				setStatus("success");
			} catch (requestError) {
				if (requestError.name !== "AbortError") {
					setError(requestError.message || "Could not reach the backend.");
					setStatus("error");
				}
			}
		}

		checkHealth();
		return () => controller.abort();
	}, [refreshKey]);

	return (
		<Container maxWidth="sm" sx={{ py: 8 }}>
			<Stack spacing={3}>
				<Box>
					<Typography variant="overline" color="text.secondary">
						SAMS · Project setup
					</Typography>
					<Typography variant="h4" component="h1" fontWeight={700}>
						Backend connection
					</Typography>
				</Box>

				<Card variant="outlined">
					<CardContent>
						<Stack spacing={2}>
							<Stack
								direction="row"
								spacing={1.5}
								sx={{ alignItems: "center" }}
							>
								<Typography variant="h6" component="h2">
									Spring Boot API
								</Typography>
								{status === "loading" ? (
									<CircularProgress size={20} aria-label="Checking backend" />
								) : (
									<Chip
										label={
											status === "success"
												? health?.status || "UP"
												: "Unavailable"
										}
										color={status === "success" ? "success" : "error"}
										size="small"
									/>
								)}
							</Stack>

							{status === "success" && (
								<Typography color="text.secondary">
									{health.application}
								</Typography>
							)}

							{status === "error" && (
								<Alert severity="error">
									{error} Make sure the backend is running on port 8080.
								</Alert>
							)}

							<Button
								variant="contained"
								onClick={() => setRefreshKey((key) => key + 1)}
								disabled={status === "loading"}>
								Check again
							</Button>
						</Stack>
					</CardContent>
				</Card>
			</Stack>
		</Container>
	);
}

export default App;
