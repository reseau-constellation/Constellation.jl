function versionValide(version::SubString{String})
    composantes = split(version, ".")
    if length(composantes) != 3
        return false
    end
    for x in composantes
        if !estNumérique(x)
            return false
        end
    end
    return true
end

function estNumérique(x)
    return tryparse(Float64, x) != nothing
end

export versionValide, estNumérique
