class Net
  def initialize topology
    @layers = topology.each_with_index.map do |neuron_count, i| 
      num_outputs = i == topology.count -1 ? 0 : topology[i+1]
      Layer.new(neuron_count, num_outputs)
    end
  end

  def feed_forward input_vals

  end

  def back_prop target_vals

  end

  def get_results

  end
end

class Layer
  def initialize neuron_count, num_outputs
    puts neuron_count
    @neurons = Array.new(neuron_count){ Neuron.new(num_outputs) }
  end
end

class Neuron
  def initialize num_outputs
    puts "made a neuron with #{num_outputs} outputs"
  end
end


topology = [3,2,1]
net = Net.new topology

input_vals = []
net.feed_forward input_vals

target_vals = []
net.back_prop target_vals

result_vals = net.get_results

