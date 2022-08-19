Mox.defmock(Attercop.ClientMock, for: Attercop.Client.ClientBehaviour)
Mox.defmock(Attercop.StubMock, for: Attercop.StubBehaviour)
ExUnit.start(exclude: [:skip])
