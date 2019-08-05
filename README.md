# Requests

Requests is a set of protocols and operations that makes integrating network requests easy and consistent. It uses a declarative style of defining a request, its result type, error type, as well as constructing the `URLRequest` and processing the data received, all in a single file. These requests can then be instantiated, configured, and passed to an `OperationQueue`.

Requests is built on top of `OperationQueue`, and each `Request` type is mapped to a specific `Operation` subclass. This allows for operation dependency chaining, so UI update operations can wait on network requests.

---

## Installation

Install using the Swift Package Manager.

---

## Documentation

### Request

`Request` is the base protocol, which defines the `Success`/`Failure` types as well as an `identifier` (which is used to implement `Equatable`).

`NetworkRequest` adds a specification for the valid HTTP status codes allowed, and an error will be thrown if a status code outside that range is received. It also adds the method for constructing the `URLRequest`.

Note: These two protocols will seldom need to be implemented directly, you will almost always use one of the specialized protocols below:

`DataRequest` returns the raw data received by the network request. Implementors are free to do whatever they need to in order to transform the data to the desired `Success` type.

`DecodableRequest` allows for direct deserialization of `Decodable` objects, and also provides properties to control decoding strategies.

`NoContentRequest` can be used when it is known the request returns no data. It will throw an error if data is returned.

### Operations

It is not intended to instantiate these operation subclasses directly, these will be created for you when adding a `Request` to a `RequestQueue`.

### RequestQueue

`RequestQueue` is a protocol that describes how to perform `Request`s. `OperationQueue` implements this protocol. The primary method is `addRequest()` (a corollary to `addOperation()`), and there are method overloads to inject a `URLSession` and a `DispatchQueue` that your completion handler should be called on. The default session is `URLSession.shared`, and the default completion queue will be operation queue's `underlyingQueue`.

---

## Usage

Typical usage will involve implementing `DataRequest`, `DecodableRequest`, or `NoContentRequest`. 

* Specify the `Success`/`Failure` types
* Implement `identifier`
* Implement `makeURLRequest(completion:)`
* If you are implementing `DataRequest` directly, implement `processData()`, otherwise `DecodableRequest`/`NoContentRequest` provide implementations of this method for you.

Example:

	struct Recipe: Decodable {
		let name: String
		let ingredients: [String]
		let steps: [String]
	}
	
	struct RecipeRequest: DecodableRequest {
		
		typealias Success = Recipe
		typealias Failure = Error
		
		var identifier: String {
			return recipeId
		}
		
		let recipeId: String
		
		func makeURLRequest(completion: @escaping (Result<URLRequest, Error>) -> Void) {
			let url = URL(string: "https://recipes.com/fakeapi/recipe/\(recipeId)")!
			let urlRequest = URLRequest(url: url)
			completion(.success(urlRequest))
		}
		
	}

Now you have a `RecipeRequest` that returns a `Recipe` on success, execute it by adding it to an `OperationQueue`:

	let queue = OperationQueue()
	let request = RecipeRequest(recipeId: "1")
	queue.addRequest(request) { result in
		switch result {
			case .success(let recipe):
				print("Recipe name: \(recipe.name)")
			case .failure(let error):
				print(error)
		}
	}

