# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

import hashlib
import tempfile
from pathlib import Path
from typing import Optional


def get_socket_path(
    root: Path, global_root: Path, relative_local_root: Optional[str]
) -> Path:
    """
    Determine where the server socket file is located. We can't directly use
    `log_directory` because of the ~100 character length limit on Unix socket
    file paths.

    Implementation needs to be kept in sync with the `user_independent_socket_path_of`
    function in `pyre/new_server/start.ml`.
    """
    project_identifier = str(global_root)
    if relative_local_root is not None:
        project_identifier = project_identifier + "//" + relative_local_root
    project_identifier = project_identifier.encode("utf-8")

    project_hash = hashlib.md5(project_identifier).hexdigest()
    return root / f"pyre_server_{project_hash}.sock"


def get_default_socket_root() -> Path:
    # TODO(T77556312): It might be cleaner to turn the root dir into a
    # configuration option instead.
    return Path(tempfile.gettempdir())


def get_default_socket_path(
    project_root: Path, relative_local_root: Optional[str]
) -> Path:
    return get_socket_path(get_default_socket_root(), project_root, relative_local_root)