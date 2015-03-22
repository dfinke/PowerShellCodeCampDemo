Enum TestEnum {
    Absent
    Present
}

function MyFunc {
    param([TestEnum]$Ensure)

    $Ensure
}

cls

MyFunc Wrong
#MyFunc Absent