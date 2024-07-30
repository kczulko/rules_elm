"""elm protobuf and grpc rules."""

load(":elm_proto_compile.bzl", _elm_proto_compile = "elm_proto_compile")
load(":elm_grpc_library.bzl", _elm_grpc_library = "elm_grpc_library")
load(":elm_proto_library.bzl", _elm_proto_library = "elm_proto_library")

# Export elm rules
elm_proto_compile = _elm_proto_compile
elm_proto_library = _elm_proto_library
elm_grpc_library = _elm_grpc_library
