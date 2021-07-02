//
// Copyright 2021 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

class VoiceMessageWaveformView: UIView {

    private let lineWidth: CGFloat = 2.0
    private let linePadding: CGFloat = 2.0
    private let renderingQueue: DispatchQueue = DispatchQueue(label: "io.element.VoiceMessageWaveformView.queue", qos: .userInitiated)

    var samples: [Float] = [] {
        didSet {
            computeWaveForm()
        }
    }
    
    var primarylineColor = UIColor.lightGray {
        didSet {
            backgroundLayer.strokeColor = primarylineColor.cgColor
            backgroundLayer.fillColor = primarylineColor.cgColor
        }
    }
    var secondaryLineColor = UIColor.darkGray {
        didSet {
            progressLayer.strokeColor = secondaryLineColor.cgColor
            progressLayer.fillColor = secondaryLineColor.cgColor
        }
    }

    private let backgroundLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    var progress = 0.0 {
        didSet {
            progressLayer.frame = CGRect(origin: self.bounds.origin, size: CGSize(width: self.bounds.width * CGFloat(self.progress), height: self.bounds.height))
        }
    }

    var requiredNumberOfSamples: Int {
        return Int(self.bounds.size.width / (lineWidth + linePadding))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupAndAdd(backgroundLayer, with: primarylineColor)
        setupAndAdd(progressLayer, with: secondaryLineColor)
        progressLayer.masksToBounds = true

        computeWaveForm()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.frame = self.bounds
        progressLayer.frame = CGRect(origin: self.bounds.origin, size: CGSize(width: self.bounds.width * CGFloat(self.progress), height: self.bounds.height))
        computeWaveForm()
    }
    
    // MARK: - Private

    private func computeWaveForm() {
        renderingQueue.async {
            let path = UIBezierPath()

            let drawMappingFactor = self.bounds.size.height
            let minimumGraphAmplitude: CGFloat = 1

            var xOffset: CGFloat = self.lineWidth / 2
            var index = 0
            
            while xOffset < self.bounds.width - self.lineWidth {
                let sample = CGFloat(index >= self.samples.count ? 1 : self.samples[index])
                let invertedDbSample = 1 - sample // sample is in dB, linearly normalized to [0, 1] (1 -> -50 dB)
                let drawingAmplitude = max(minimumGraphAmplitude, invertedDbSample * drawMappingFactor)

                path.move(to: CGPoint(x: xOffset, y: self.bounds.midY - drawingAmplitude / 2))
                path.addLine(to: CGPoint(x: xOffset, y: self.bounds.midY + drawingAmplitude / 2))

                xOffset += self.lineWidth + self.linePadding

                index += 1
            }

            DispatchQueue.main.async {
                self.backgroundLayer.path = path.cgPath
                self.progressLayer.path = path.cgPath
            }
        }
    }
    
    private func setupAndAdd(_ shapeLayer: CAShapeLayer, with color: UIColor) {
//        shapeLayer.shouldRasterize = true
        shapeLayer.drawsAsynchronously = true
        shapeLayer.frame = self.bounds
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = color.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.lineWidth = lineWidth
        self.layer.addSublayer(shapeLayer)
    }
}
