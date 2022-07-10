def render_path($path):
    if $simplify_paths then
        $path | capture("^/nix/store/[a-zA-Z0-9]{26}(?<name>.*)$") | .name
    else
        $path
    end;

def round1:
    .*10 | round | ./10
    ;

def size_pretty:
    .
    | 1024 as $kb
    | (1024 * 1024) as $mb
    | (1024 * 1024 * 1024) as $gb
    | if . > $gb then
        "\(. / $gb | round1) GiB"
    elif . > $mb then
        "\(. / $mb | round1) MiB"
    elif . > $kb then
        "\(. / $kb | round1) KiB"
    else
        "\(.) bytes"
    end;

def graphedge:
    # debug |
    .path as $origpath
    | render_path(.path) as $path
    | .references[]
    | select(. != $origpath)
    | "\"\($path)\" -> \"\(render_path(.))\";"
    ;

def graphnode:
    # debug |
    (.path | render_path(.)) as $node
    | (.narSize | size_pretty) as $size
    | (.closureSize | size_pretty) as $closureSize
    | "\"\($node)\" [label = \"\($node)\\n\($size) / \($closureSize)\"];"
    ;

"digraph G {\n",
(.[] | (graphnode, graphedge)),
"}"

