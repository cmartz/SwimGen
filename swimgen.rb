

$strokes = {:fly => 0, :back => 1, :breast => 2, :free => 3}
$strokes_lookup = $strokes.invert

$pool_lengths = {:scy => 25, :scm => 25, :lcm => 50}
$pool_length = nil

# => Inputs:
# => Outputs:
# => Purpose:
def InitPoolLength(length)
  if length == "scy" or length == nil
    $pool_length = $pool_lengths[:scy]
  elsif length == "scm"
    $pool_length = $pool_lengths[:scm]
  elsif length == "lcm"
    $pool_length = $pool_lengths[:lcm]
  else
    #Undefined pool length, throw error and abort
  end

  puts $pool_length
end

# => Inputs:
# => Outputs:
# => Purpose:
def GetPoolLength
  return $pool_length
end

# => Inputs:
# => Outputs:
# => Purpose:
def LapsToLength(numLaps)
  return numLaps * GetPoolLength()
end

# => Inputs:
# => Outputs:
# => Purpose:
def LengthToLaps(length)
  return length / GetPoolLength()
end

# => Inputs:
# => Outputs:
# => Purpose:
def InitEngine
  args = Hash[ ARGV.flat_map{|s| s.scan(/--?([^=\s]+)(?:=(\S+))?/) } ]
  InitPoolLength(args['pl'])
end

#########################################################################

# => Inputs:
# => Outputs:
# => Purpose:
def GenSymSet(lapsPerRep, maxLaps, lapSet)
  numReps = (maxLaps / lapsPerRep).floor

  set = lapSet.repeated_permutation(lapsPerRep).to_a

  #Make this more efficient later, feeling lazy AF
  while LapsToLength(lapsPerRep * set.size) > maxLaps
    set.pop
  end

  return set
end

#THIS NEEDS TO BE TESTED
# => Inputs:
# => Outputs:
# => Purpose:
def GenBuildSet(increment, initialLaps, maxLaps, lapSet)
  #Spec this out: (12/9/14) How do I specify how to assign from the lap set?

  #Make the stroke dynamic later
  initialRep = Array.new(initialLaps, $strokes[:free])
  buildSet = [initialRep]
  currentLaps = initialLaps
  currentLevel = initialLaps

  while currentLaps < maxLaps
    currentLevel += increment
    currentLaps += currentLevel
    buildSet.push(Array.new(currentLevel, $strokes[:free]))
  end

  return buildSet

end

# => Inputs:
# => Outputs:
# => Purpose:
def QuickSet
  fiveHundredFree = Array.new(20, $strokes[:free])
  basicWarmup = [fiveHundredFree]
  techWarmup = GenSymSet(3, 500, [$strokes[:free], $strokes[:back]])
  warmup = [basicWarmup, techWarmup]

  hundredFree = Array.new(4, $strokes[:free])
  mainSet = Array.new(10, hundredFree)
  otherSet = GenBuildSet(2, 2, 20, [$strokes[:free], $strokes[:back]])
  main = [mainSet, otherSet]

  warmDownSet = [fiveHundredFree]
  coolDown = [warmDownSet]

  set = {:warmup => warmup, :main => main, :cooldown => coolDown}
  return set
end

# => Inputs:
# => Outputs:
# => Purpose:
def SetToString(set)
  setString = ""
  last_lap = nil
  lap_count = 0
  set.each do |lap|
    if lap == last_lap or last_lap == nil
      lap_count += 1
    else
      setString += " " + LapsToLength(lap_count).to_s + " " + $strokes_lookup[last_lap].to_s
      lap_count = 1
    end
    last_lap = lap
  end
  setString += " " + LapsToLength(lap_count).to_s + " " + $strokes_lookup[last_lap].to_s
  return setString
end

# => Inputs:
# => Outputs:
# => Purpose:
def PrintSet(set)
  puts "Warm Up: "
  set[:warmup].each do |warmupSet|
    warmupSet.each do |subset|
      puts "\t\t" + (subset.size * GetPoolLength()).to_s + ": " + SetToString(subset)
    end
  end

  puts "Main Set: "
  set[:main].each do |mainSet|
    mainSet.each do |subset|
      puts "\t\t" + (subset.size * GetPoolLength()).to_s + ": " + SetToString(subset)
    end
  end

  puts "Cool Down: "
  set[:cooldown].each do |cooldownSet|
    cooldownSet.each do |subset|
      puts "\t\t" + (subset.size * GetPoolLength()).to_s + ": " + SetToString(subset)
    end
  end
end

#########################################################################
InitEngine()

set = QuickSet()

PrintSet(set)
