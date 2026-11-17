import React from "react";
import Button from "@mui/material/Button";

function App() {
	return (
		<div>
			<AppButton />
		</div>
	);
}

function AppButton() {
	return <Button variant="contained">Hello world</Button>;
}

export default App;
