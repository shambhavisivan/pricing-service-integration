export class InvalidExpressionError extends Error {
	constructor(public message: string) {
		super(message);
	}
}
