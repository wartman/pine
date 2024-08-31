// This code is *heavily* based on Angular's signal implementation (specifically
// the "graph.ts" file). It's basically a direct port with a little bit of modification.
//
// Source code: https://github.com/angular/angular/blob/4be253483d045cfee6b42766c9dfd8c9888057e0/packages/core/primitives/signals/src/graph.ts
//
// Google's license:
// "Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file at https://angular.io/license"
package pine.signal;

import pine.debug.Debug;

typedef ReactiveNodeLink = {
	public var foreignIndex:Int;
	public var node:ReactiveNode;
}

typedef ReactiveNodeProducerLink = ReactiveNodeLink & {
	public var lastSeenVersion:ReactiveNodeVersion;
}

typedef ReactiveNodeVersion = Int;

enum abstract ReactiveNodeStatus(Int) {
	final Valid = 0;
	final Invalid = 1;
}

typedef ReactiveNodeOptions = {
	public final ?alwaysLive:Bool;
	public final ?forceValidation:(node:ReactiveNode) -> Bool;
}

@:allow(pine.signal)
class ReactiveNode {
	final runtime:Runtime;
	final onValidate:Null<(node:ReactiveNode) -> Void>;
	final forceValidation:(node:ReactiveNode) -> Bool;
	final alwaysLive:Bool;

	var version:ReactiveNodeVersion = 0;
	var lastValidEpoch:Int = 0;
	var producers:Null<Array<ReactiveNodeProducerLink>> = null;
	var producerNextIndex:Int = 0;
	var consumers:Null<Array<ReactiveNodeLink>> = null;
	var status:ReactiveNodeStatus = Valid;

	public function new(?runtime, ?onValidate, ?options:ReactiveNodeOptions) {
		this.runtime = runtime ?? Runtime.current();
		this.onValidate = onValidate;
		this.alwaysLive = options?.alwaysLive ?? false;
		this.forceValidation = options?.forceValidation ?? _ -> false;
	}

	public function isLive() {
		return alwaysLive || (consumers?.length ?? 0) > 0;
	}

	public function accessed() {
		runtime.currentConsumer()?.addProducer(this);
	}

	public function useAsCurrentConsumer(effect:() -> Void) {
		runtime.assertNotNotifying();

		producerNextIndex = 0;
		ensureConsumerNode();

		runtime.track(this, () -> effect(), () -> {
			if (isLive()) for (index in producerNextIndex...producers.length) {
				var link = producers[index];
				link.node.removeConsumerAt(link.foreignIndex);
			}
			producers = producers.slice(0, producerNextIndex);
		});
	}

	public function notify() {
		if (consumers == null) return;

		runtime.whileNotifying(() -> for (link in consumers) {
			link.node.invalidate();
		});
	}

	public function invalidate() {
		if (status == Invalid) return;
		status = Invalid;
		notify();
		runtime.schedule(() -> validate());
	}

	public function validate() {
		var epoch = runtime.epoch;

		if (!forceValidation(this)) {
			if (isLive() && status == Valid) return;
			if (status == Valid && epoch == lastValidEpoch) return;

			if (!pollProducers()) {
				status = Valid;
				lastValidEpoch = epoch;
				return;
			}
		}

		// @todo: Lock signal writing here?
		if (onValidate != null) onValidate(this);

		status = Valid;
		lastValidEpoch = epoch;
	}

	function pollProducers():Bool {
		ensureConsumerNode();

		for (link in producers) {
			var lastSeenVersion = link.lastSeenVersion;
			if (lastSeenVersion != link.node.version) return true;
			link.node.validate();
			if (lastSeenVersion != link.node.version) return true;
		}

		return false;
	}

	public function addProducer(producer:ReactiveNode) {
		runtime.assertNotNotifying();

		ensureConsumerNode();
		producer.ensureProducerNode();

		var index = producerNextIndex++;

		if (index < producers.length && producers[index]?.node != producer) {
			if (isLive()) {
				var oldLink = producers[index];
				oldLink.node.removeConsumerAt(oldLink.foreignIndex);
			}
		}

		if (producers[index]?.node != producer) {
			producers[index] = {
				node: producer,
				foreignIndex: isLive() ? producer.addConsumerAt(index, this) : 0,
				lastSeenVersion: producer.version
			};
			return;
		}

		producers[index].lastSeenVersion = producer.version;
	}

	public function addConsumerAt(index:Int, consumer:ReactiveNode):Int {
		runtime.assertNotNotifying();

		ensureProducerNode();
		consumer.ensureConsumerNode();

		// When going from 0 to 1 consumers, notify any producers
		// that this node is now live.
		if (consumers.length == 0 && producers != null) {
			for (index => link in producers) {
				link.foreignIndex = link.node.addConsumerAt(index, this);
			}
		}

		return consumers.push({
			node: consumer,
			foreignIndex: index
		}) - 1;
	}

	public function removeConsumerAt(index:Int) {
		ensureProducerNode();
		ensureConsumerNode();

		assert(consumers.length >= index, 'Consumer index ${index} is out of bounds of ${consumers.length}');

		// If we're removing the last consumer from this node its producers
		// no longer need to update it.
		if (consumers.length == 1) for (link in producers) {
			link.node.removeConsumerAt(link.foreignIndex);
		}

		// Move the last link in our consumers array into the spot that
		// just became available. If there's only a single consumer
		// this will effectively clear the array.
		var lastIndex = consumers.length - 1;
		var link = consumers[lastIndex];

		consumers[index] = link;
		consumers.resize(lastIndex > 0 ? lastIndex : 0);

		// If the index is still valid, update the link's pointers
		// to the new index.
		if (index < consumers.length) {
			link.node.ensureConsumerNode();
			link.node.producers[link.foreignIndex].foreignIndex = index;
		}
	}

	public function disconnect() {
		ensureConsumerNode();

		if (isLive()) for (link in producers) {
			link.node.removeConsumerAt(link.foreignIndex);
		}

		producers?.resize(0);
		consumers?.resize(0);
	}

	function ensureProducerNode() {
		consumers ??= [];
	}

	function ensureConsumerNode() {
		producers ??= [];
	}
}
