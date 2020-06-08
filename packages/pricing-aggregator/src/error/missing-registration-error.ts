export class MissingRegistrationError extends Error {
	constructor(public message: string) {
		super(message);
	}
}
