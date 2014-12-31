require "csv"
require_relative "Lap.rb"

$strokes = {:fly => 0, :back => 1, :breast => 2, :free => 3}
$strokes_lookup = $strokes.invert

$pool_lengths = {:scy => 25, :scm => 25, :lcm => 50}
$pool_length = nil

$flyTempoInt
$backTempoInt
$breastTempoInt
$freeTempoInt

# => Inputs:  freeTempo - The freestyle tempo interval for 100yds in seconds
#
# => Outputs: N/A
#
# => Purpose: To initialize the tempo interval variables
#
def InitTempoIntervals(freeTempo)
  freeTempo = (freeTempo.to_i) / (100 / GetPoolLength())  # Scale to one lap.
  $flyTempoInt    = (freeTempo * 1.17).ceil # 7/6 * freeTempo
  $backTempoInt   = (freeTempo * 1.11).ceil # 10/9 * freeTempo
  $breastTempoInt = (freeTempo * 1.33).ceil # 4/3 * freeTempo
  $freeTempoInt   = freeTempo
end

# => Inputs: query  -
#            source - The data source to query the lap set from
#
# => Outputs: The results of the lapset query
#
# => Purpose: To query a lap set from a specified data source
#
def GetLapSet(query, source)
  if source == "TEST"
    #Get lap set from test data csv
    #Should this be made into a separate method?
    CSV.foreach("test_data.csv") do |row|
      #Add in case for empty rows
      l = Lap.new(row[0].to_s, $strokes[row[1].to_s], row[2].to_s)
    end
  else
    #Get lap set from database
  end
end

# => Inputs: focus - The command line argument for the session focus
#
# => Outputs: N/A
#
# => Purpose: To initialize the $focus varible
#
def InitLapSet(focus)
  if focus == "swim" or focus == "s"
    GetLapSet(focus, "TEST")
  elsif focus == "drill" or focus == "d"
  elsif focus == "kick" or focus == "k"
  else
    #Undefined set focus, throw error and abort
    abort("Invalid session focus")
  end
end

# => Inputs: length - The command line argument for the pool length.
#
# => Outputs: N/A
#
# => Purpose: To initialize the $pool_length variable.
#
def InitPoolLength(length)
  if length == "scy" or length == nil
    $pool_length = $pool_lengths[:scy]
  elsif length == "scm"
    $pool_length = $pool_lengths[:scm]
  elsif length == "lcm"
    $pool_length = $pool_lengths[:lcm]
  else
    #Undefined pool length, throw error and abort
    abort("Invalid pool format.")
  end
end

# => Inputs: N/A
#
# => Outputs: The specified length of the pool.
#
# => Purpose: Provide a common interface to the pool length variable
#
def GetPoolLength
  return $pool_length
end

# => Inputs: numLaps - The number of laps to be converted to distance.
#
# => Outputs: The distance equivalent to numlaps.
#
# => Purpose: Convert from laps to distance.
#
def LapsToLength(numLaps)
  return numLaps * GetPoolLength()
end

# => Inputs: length - distance to be converted into number of laps
#
# => Outputs: The number of pool lengths equivalent to length.
#
# => Purpose: Convert from distance to laps
#
def LengthToLaps(length)
  return length / GetPoolLength()
end

# => Inputs: N/A
#
# => Outputs: N/A
#
# => Purpose: This is the application orchestrator that gathers the program
#             inputs and takes appropriate action to produce the requested
#             program output. This should be called only once per application
#             execution and should never be called by an outside program.
#
def InitEngine
  args = Hash[ ARGV.flat_map{|s| s.scan(/--?([^=\s]+)(?:=(\S+))?/) } ]
  InitPoolLength(args['pl'])
  InitLapSet(args['f'])
  InitTempoIntervals(args['fti'])
end

#########################################################################

# => Inputs: lapsPerRep - Number of laps in each discrete rep.
#            maxLaps    - Maximum (or minimum) size of a rep.
#            lapSet     - The set of laps available for use in reps.
#
# => Outputs: A set array.
#
# => Purpose: To create a set of lapsPerRep sized reps whose total sum
#             does not exceed maxLaps comprising of permutations of lapSet.
#
def GenSymSet(lapsPerRep, maxLaps, lapSet)
  numReps = (maxLaps / lapsPerRep).floor

  set = lapSet.repeated_permutation(lapsPerRep).to_a

  #Make this more efficient later, feeling lazy AF
  while LapsToLength(lapsPerRep * set.size) > maxLaps
    set.pop
  end

  return set
end

# => Inputs: Increment   - Amount by which reps grow or shrink
#            initialLaps - Starting number of laps
#            maxLaps     - Maximum (or minimum) size of a rep
#            lapSet      - The set of laps available for use in reps
#
# => Outputs: A set array containing the build set
#
# => Purpose: To build a set comprising of laps from lapSet that grows or
#             shrinks at a constant rate (increment) until it hits the
#             a specified limit (maxLaps).
#
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

# => Inputs: N/A
#
# => Outputs: A complete session.
#
# => Purpose: Create a fairly basic session. The session comprises of
#             a warmup (500 free, 6 x 75 free/back), a main set (10 x 100 free,
#             50->200 free in increments of 50), and a cool down (500 free)
#
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

# => Inputs: set - The set to be converted into a string.
#
# => Outputs: The resulting string
#
# => Purpose: Convert sets into strings for easy-to-read printing
#
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

# => Inputs: session - The session to be printed.
#
# => Outputs: N/A
#
# => Purpose: Print the entire session in an aesthetic format.
#
def PrintSet(session)
  puts "Warm Up: "
  session[:warmup].each do |warmupSet|
    warmupSet.each do |subset|
      puts "\t\t" + (subset.size * GetPoolLength()).to_s + ": " + SetToString(subset)
    end
  end

  puts "Main Set: "
  session[:main].each do |mainSet|
    mainSet.each do |subset|
      puts "\t\t" + (subset.size * GetPoolLength()).to_s + ": " + SetToString(subset)
    end
  end

  puts "Cool Down: "
  session[:cooldown].each do |cooldownSet|
    cooldownSet.each do |subset|
      puts "\t\t" + (subset.size * GetPoolLength()).to_s + ": " + SetToString(subset)
    end
  end
end

#########################################################################
InitEngine()

set = QuickSet()

PrintSet(set)

l = Lap.new('Easy Free', $strokes[:free], 'swim')
puts l.get_name
