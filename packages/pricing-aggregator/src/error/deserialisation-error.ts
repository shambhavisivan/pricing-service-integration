export class DeserializationError extends Error {
	constructor(public message: string) {
		super(message);
	}
}
